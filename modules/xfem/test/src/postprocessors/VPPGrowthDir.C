//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "VPPGrowthDir.h"

// MOOSE includes
#include "Function.h"
#include "MooseMesh.h"
#include "MooseVariable.h"
#include "SubProblem.h"

#include "libmesh/system.h"

registerMooseObject("MooseApp", VPPGrowthDir);

template <>
InputParameters
validParams<VPPGrowthDir>()
{
  InputParameters params = validParams<GeneralPostprocessor>();
  return params;
}

VPPGrowthDir::VPPGrowthDir(const InputParameters & parameters)
  : GeneralPostprocessor(parameters),
    _cutter(&_fe_problem.getUserObject<MeshCut3DUserObject>("cut_mesh"))  // should be deleted
{
}

void
VPPGrowthDir::initialize()
{
  _avr = 0;
}

void
VPPGrowthDir::execute()
{
  // get KI and KII at front nodes
  const VectorPostprocessorValue & k1 = getVectorPostprocessorValueByName(_vpp_type[0],_vpp_name[0]);
  const VectorPostprocessorValue & k2 = getVectorPostprocessorValueByName(_vpp_type[1],_vpp_name[1]);
  mooseAssert(k1.size()==k2.size(), "KI and KII VPPs should have the same size");
  for (unsigned int i = 0; i < k1.size(); ++i)
  {
    _growth_dir.push_back(k1[i]+k2[i]);
    std::cout << k1[i] << ',' << k2[i] << std::endl;
  }
}

Real
VPPGrowthDir::getValue()
{
  return _avr;
}
