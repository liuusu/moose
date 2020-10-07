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
class PPFatigue;

template <>
InputParameters validParams<PPFatigue>();

/**
 * Compute the value of a variable at a specified location.
 *
 * Warning: This postprocessor may result in undefined behavior if utilized with
 * non-continuous elements and the point being located lies on an element boundary.
 */
class PPFatigue : public GeneralPostprocessor
{
public:
  PPFatigue(const InputParameters & parameters);

  virtual void initialize() override;
  virtual void execute() override;
  virtual void finalize() override {}
  virtual Real getValue() override;

protected:
  /// The value of the variable at the desired location
  unsigned long int _dN_this;
  MeshCut3DUserObject * _cutter;
  Real _max_growth_size;
  Real _paris_law_c;
  Real _paris_law_m;

  /// Effective K for active boundaries
  std::vector<Real> _effective_K;
  std::vector<Real> _growth_size;

  /// Maximum effective K
  Real _max_K;

  /// Fatigue life
  std::vector<unsigned long int> _dN;
  std::vector<unsigned long int> _N;
  std::vector<Real> _max_K_his;
};
