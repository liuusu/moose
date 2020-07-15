//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "GeneralPostprocessor.h"
#include "MeshCut3DUserObject.h"

// Forward Declarations
class VPPGrowthDir;

template <>
InputParameters validParams<VPPGrowthDir>();

/**
 * Compute the value of a variable at a specified location.
 *
 * Warning: This postprocessor may result in undefined behavior if utilized with
 * non-continuous elements and the point being located lies on an element boundary.
 */
class VPPGrowthDir : public GeneralPostprocessor
{
public:
  VPPGrowthDir(const InputParameters & parameters);

  virtual void initialize() override;
  virtual void execute() override;
  virtual void finalize() override {}
  virtual Real getValue() override;

protected:
  const std::string _vpp_type[2] = {"II_KI_1","II_KII_1"};
  const std::string _vpp_name[2] = {"II_KI_1","II_KII_1"};
  MeshCut3DUserObject * _cutter;
  std::vector<Real> _growth_dir;
  Real _avr;
};
