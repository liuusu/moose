[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  volumetric_locking_correction = true
[]

[XFEM]
  qrule = volfrac
  output_cut_plane = true
[]

[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 17
  ny = 17
  nz = 3
  xmin = -0.5
  xmax = 0.5
  ymin = -0.5
  ymax = 0.5
  zmin = -0.25
  zmax = 0.25
  elem_type = HEX8
[]

[UserObjects]
  [./circle_cut_uo]
    type = CircleCutUserObject
    cut_data = '-0.5 -0.5 0
                0.0 -0.5 0
                -0.5 0.0 0'
  [../]
[]

[AuxVariables]
  [./SED]
   order = CONSTANT
    family = MONOMIAL
  [../]
[]

[DomainIntegral]
  integrals = 'Jintegral InteractionIntegralKI InteractionIntegralKII'
  disp_x = disp_x
  disp_y = disp_y
  disp_z = disp_z
  crack_front_points = '-0.500	0.000	0.000
                        -0.451	-0.002	0.000
                        -0.402	-0.010	0.000
                        -0.355	-0.022	0.000
                        -0.309	-0.038	0.000
                        -0.264	-0.059	0.000
                        -0.222	-0.084	0.000
                        -0.183	-0.114	0.000
                        -0.146	-0.146	0.000
                        -0.113	-0.183	0.000
                        -0.084	-0.222	0.000
                        -0.059	-0.264	0.000
                        -0.038	-0.309	0.000
                        -0.022	-0.355	0.000
                        -0.010	-0.402	0.000
                        -0.002	-0.451	0.000
                        0.000	-0.500	0.000'
  crack_end_direction_method = CrackDirectionVector
  crack_direction_vector_end_1 = '0 1 0'
  crack_direction_vector_end_2 = '1 0 0'
  crack_direction_method = CurvedCrackFront
  intersecting_boundary = '1 4' #It would be ideal to use this, but can't use with XFEM yet
  radius_inner = '0.3'
  radius_outer = '0.6'
  poissons_ratio = 0.3
  youngs_modulus = 207000
  block = 0
  incremental = true
[]

[Modules/TensorMechanics/Master]
  [./all]
    strain = FINITE
    add_variables = true
    generate_output = 'stress_xx stress_yy stress_zz vonmises_stress'
  [../]
[]

[AuxKernels]
  [./SED]
    type = MaterialRealAux
    variable = SED
    property = strain_energy_density
    execute_on = timestep_end
    block = 0
  [../]
[]

[Functions]
  [./top_trac_z]
    type = ConstantFunction
    value = 10
  [../]
[]


[BCs]
  [./top_z]
    type = FunctionNeumannBC
    boundary = front
    variable = disp_z
    function = top_trac_z
  [../]
  [./bottom_x]
    type = DirichletBC
    boundary = back
    variable = disp_x
    value = 0.0
  [../]
  [./bottom_y]
    type = DirichletBC
    boundary = back
    variable = disp_y
    value = 0.0
  [../]
  [./bottom_z]
    type = DirichletBC
    boundary = back
    variable = disp_z
    value = 0.0
  [../]
  [./sym_y]
    type = DirichletBC
    boundary = bottom
    variable = disp_y
    value = 0.0
  [../]
  [./sym_x]
    type = DirichletBC
    boundary = left
    variable = disp_x
    value = 0.0
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 207000
    poissons_ratio = 0.3
  [../]
  [./stress]
    type = ComputeFiniteStrainElasticStress
  [../]
[]

[Executioner]
  type = Transient

  solve_type = 'PJFNK'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  petsc_options_value = '201                hypre    boomeramg      8'

  line_search = 'none'

  [./Predictor]
    type = SimplePredictor
    scale = 1.0
  [../]

# controls for linear iterations
  l_max_its = 100
  l_tol = 1e-2

# controls for nonlinear iterations
  nl_max_its = 15
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-10

# time control
  start_time = 0.0
  dt = 1.0
  end_time = 1.0
[]

[Outputs]
  file_base = out/penny_crack_out
  execute_on = timestep_end
  exodus = true
  [./console]
    type = Console
    output_linear = true
  [../]
[]
