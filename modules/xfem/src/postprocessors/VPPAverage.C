//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "VPPAverage.h"

// MOOSE includes
#include "Function.h"
#include "MooseMesh.h"
#include "MooseVariable.h"
#include "SubProblem.h"

#include "libmesh/system.h"

registerMooseObject("MooseApp", VPPAverage);

template <>
InputParameters
validParams<VPPAverage>()
{
  InputParameters params = validParams<GeneralPostprocessor>();
  params.addRequiredParam<std::string>("vpp_type","vpp type to be averaged over the front nodes");
  params.addRequiredParam<std::string>("vpp_name","vpp name to be averaged over the front nodes");
  return params;
}

VPPAverage::VPPAverage(const InputParameters & parameters)
  : GeneralPostprocessor(parameters),
    _vpp_type(getParam<std::string>("vpp_type")),
    _vpp_name(getParam<std::string>("vpp_name")),
    _cutter(&_fe_problem.getUserObject<MeshCut3DUserObject>("cut_mesh"))
{
}

void
VPPAverage::initialize()
{
  _avr = 0;
}

void
VPPAverage::execute()
{
  const VectorPostprocessorValue & vpp_values = getVectorPostprocessorValueByName(_vpp_type,_vpp_name);
  for (unsigned int i = 0; i < vpp_values.size(); ++i)
    _avr += vpp_values[i];
  _avr /= vpp_values.size();
  std::cout << "current average value: " << _avr << std::endl;
}

Real
VPPAverage::getValue()
{
  return _avr;
}
