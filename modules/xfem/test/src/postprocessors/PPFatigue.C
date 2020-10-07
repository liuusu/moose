//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "PPFatigue.h"

// MOOSE includes
#include "Function.h"
#include "MooseMesh.h"
#include "MooseVariable.h"
#include "SubProblem.h"

#include "libmesh/system.h"

registerMooseObject("MooseApp", PPFatigue);

template <>
InputParameters
validParams<PPFatigue>()
{
  InputParameters params = validParams<GeneralPostprocessor>();
  params.addParam<Real>(
      "max_growth_size", "the max growth size at the crack front in each increment of a fatigue simulation");
  params.addParam<Real>(
      "paris_law_c", "parameter C in the Paris law for fatigue");
  params.addParam<Real>(
      "paris_law_m", "parameter m in the Paris law for fatigue");
  return params;
}

PPFatigue::PPFatigue(const InputParameters & parameters)
  : GeneralPostprocessor(parameters),
    _cutter(&_fe_problem.getUserObject<MeshCut3DUserObject>("cut_mesh")) // should be deleted
{
  if (!isParamValid("max_growth_size") || !isParamValid("paris_law_c") || !isParamValid("paris_law_m"))
    mooseError("max_growth_size and C & m of the Paris law are required parameters for the fatigue simulation");

  _max_growth_size = getParam<Real>("max_growth_size");
  _paris_law_c = getParam<Real>("paris_law_c");
  _paris_law_m = getParam<Real>("paris_law_m");
}

void
PPFatigue::initialize()
{
  _dN_this = 0;
}

void
PPFatigue::execute()
{
  // Generate _active_boundary and _inactive_boundary_pos;
  // This is a duplicated call before the one in MeshCut3DUserObject;
  // That one cannot be deleted because this one is for subcritical cracking only.
  _cutter->findActiveBoundaryNodes();

  // Crack front definition using the cutter mesh currently only supports one active crack front segment
  auto active_boundary = _cutter->_active_boundary;
  unsigned int ibnd = 0;
  unsigned int size_this_segment = active_boundary[ibnd].size();

  auto inactive_boundary_pos = _cutter->_inactive_boundary_pos;
  unsigned int n_inactive_nodes = inactive_boundary_pos.size();

  auto crack_front_points = _cutter->_crack_front_points;

  const VectorPostprocessorValue & k1 = getVectorPostprocessorValueByName("II_KI_1","II_KI_1");
  const VectorPostprocessorValue & k2 = getVectorPostprocessorValueByName("II_KII_1","II_KII_1");
  mooseAssert(k1.size()==k2.size(), "KI and KII VPPs should have the same size");
  mooseAssert(k1.size()==size_this_segment, "the number of crack front nodes in the self-similar method should equal to the size of VPP defined at the crack front");

  _effective_K.clear();

  // _active_boundary.size() = 1
  for (unsigned int i = 0; i < active_boundary.size(); ++i)
  {
    std::vector<Real> temp_K;

    if (n_inactive_nodes != 0)
      temp_K.push_back(0.0);

    unsigned int i1 = n_inactive_nodes == 0 ? 0 : 1;
    unsigned int i2 = n_inactive_nodes == 0 ? size_this_segment : size_this_segment-1;

    // loop over active front points
    for (unsigned int j = i1; j < i2; ++j)
    {
      dof_id_type id = active_boundary[i][j];
      auto it = std::find(crack_front_points.begin(), crack_front_points.end(), id);
      unsigned int index = std::distance(crack_front_points.begin(), it);

      Real effective_K = sqrt(pow(k1[index],2) + 2 * pow(k2[index],2));
      temp_K.push_back(effective_K);
    }

    if (n_inactive_nodes != 0)
      temp_K.push_back(0.0);

    _effective_K.push_back(temp_K);
  }

  _max_K = std::numeric_limits<double>::lowest();
  for (const auto& v : _effective_K)
  {
      Real current_max = *std::max_element(v.cbegin(), v.cend());
      _max_K = _max_K < current_max ? current_max : _max_K;
  }

  for (unsigned int i = 0; i < _effective_K.size(); ++i)
    writeVectorReal(_effective_K[i],"effective K +++++++++++");

  // calculate dN
  unsigned long int _dN_this = (unsigned long int) (_max_growth_size / (_paris_law_c * pow(_max_K, _paris_law_m)));
  _dN.push_back(_dN_this);
  _N.push_back(_N.size() == 0 ? _dN_this : _dN_this + _N[_N.size()-1]);
  _max_K_his.push_back(_max_K);

  writeVectorLongInt(_dN,"dN");
  writeVectorLongInt(_N,"N");
  writeVectorReal(_max_K_his,"max K");

  // _active_boundary.size() = 1
  for (unsigned int i = 0; i < active_boundary.size(); ++i)
  {
    std::vector<Real> temp_s;

    if (n_inactive_nodes != 0)
      temp_s.push_back(0.0);

    unsigned int i1 = n_inactive_nodes == 0 ? 0 : 1;
    unsigned int i2 = n_inactive_nodes == 0 ? size_this_segment : size_this_segment-1;

    // loop over active front points
    for (unsigned int j = i1; j < i2; ++j)
    {
      Real effective_K = _effective_K[i][j];
      Real growth_size = _max_growth_size * pow(effective_K/_max_K, _paris_law_m);
      temp_s.push_back(growth_size);
      std::cout << growth_size << "growth" << std::endl;
    }

    if (n_inactive_nodes != 0)
      temp_s.push_back(0.0);

    _growth_size.push_back(temp_s);
  }
}

Real
PPFatigue::getValue()
{
  return _dN_this;
}

void
PPFatigue::writeVector(std::vector<dof_id_type> & vec, std::string name)
{
  std::cout << name << ": " << std::endl;
  for (unsigned int i = 0; i < vec.size(); ++i)
  {
    std::cout << vec[i] << std::endl;
  }
}

void
PPFatigue::writeVectorReal(std::vector<Real> & vec, std::string name)
{
  std::cout << name << ": " << std::endl;
  for (unsigned int i = 0; i < vec.size(); ++i)
  {
    std::cout << vec[i] << std::endl;
  }
}

void
PPFatigue::writeVectorLongInt(std::vector<unsigned long int> & vec, std::string name)
{
  std::cout << name << ": " << std::endl;
  for (unsigned int i = 0; i < vec.size(); ++i)
  {
    std::cout << vec[i] << std::endl;
  }
}
