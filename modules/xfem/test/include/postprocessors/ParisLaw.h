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
class ParisLaw;

template <>
InputParameters validParams<ParisLaw>();

/**
 * Compute the value of a variable at a specified location.
 *
 * Warning: This postprocessor may result in undefined behavior if utilized with
 * non-continuous elements and the point being located lies on an element boundary.
 */
class ParisLaw : public GeneralPostprocessor
{
public:
  ParisLaw(const InputParameters & parameters);

  virtual void initialize() override;
  virtual void execute() override;
  virtual void finalize() override {}
  virtual Real getValue() override;

protected:
  /// Cutter mesh
  MeshCut3DUserObject * _cutter;
  /// Number of cycles for this growth increament
  unsigned long int _dN;
  /// Length of crack growth at the point with largest K
  Real _max_growth_size;
  /// Paris law parameters
  Real _paris_law_c;
  Real _paris_law_m;
  /// Effective K for active cutter nodes
  std::vector<Real> _effective_K;
  /// Growth length for active cutter nodes
  std::vector<Real> _growth_size;
  /// Maximum effective K
  Real _max_K;
};
