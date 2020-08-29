[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  volumetric_locking_correction = true
[]

[XFEM]
  geometric_cut_userobjects = 'cut_mesh'
  qrule = volfrac
  output_cut_plane = true
[]

[Mesh]
  file = quarter_sym.e
[]

[UserObjects]
  [./cut_mesh]
    type = MeshCut3DUserObject
    mesh_file = mesh_penny_crack.xda
    size_control = 0.125
    n_step_growth = 1
    growth_dir_method = 'max_hoop_stress'
    function_x = growth_func_x
    function_y = growth_func_y
    function_z = growth_func_z
    function_v = growth_func_v
    crack_front_nodes = '5 4 3 2 1'
  [../]
[]

[Functions]
  [./growth_func_x]
    type = ParsedFunction
    value = (x+0.5)
  [../]
  [./growth_func_y]
    type = ParsedFunction
    value = (y+0.5)
  [../]
  [./growth_func_z]
    type = ParsedFunction
    value = z
  [../]
  [./growth_func_v]
    type = ParsedFunction
    vars = 'j'
    vals = 'j_avr'
    value = j*25000
  [../]
[]

[DomainIntegral]
  integrals = 'Jintegral'
  displacements = 'disp_x disp_y disp_z'
  crack_front_points_provider = cut_mesh
  number_points_from_provider = 5
  crack_end_direction_method = CrackDirectionVector
  crack_direction_vector_end_1 = '0 1 0'
  crack_direction_vector_end_2 = '1 0 0'
  crack_direction_method = CurvedCrackFront
  intersecting_boundary = '3 4' #It would be ideal to use this, but can't use with XFEM yet
  radius_inner = '0.3'
  radius_outer = '0.6'
  poissons_ratio = 0.3
  youngs_modulus = 207000
  block = 1
  incremental = true
  solid_mechanics = true
[]

[Modules/TensorMechanics/Master]
  [./all]
    strain = FINITE
    add_variables = true
    generate_output = 'stress_xx stress_yy stress_zz vonmises_stress'
  [../]
[]

[Functions]
  [./top_trac_z]
    type = ConstantFunction
    value = 10
  [../]
[]

[Postprocessors]
  [./j_avr]
    type = VPPAverage
    vpp_type = 'J_1'
    vpp_name = 'J_1'
  [../]
[]

[BCs]
  [./top_z]
    type = FunctionNeumannBC
    boundary = 2
    variable = disp_z
    function = top_trac_z
  [../]
  [./bottom_x]
    type = DirichletBC
    boundary = 1
    variable = disp_x
    value = 0.0
  [../]
  [./bottom_y]
    type = DirichletBC
    boundary = 1
    variable = disp_y
    value = 0.0
  [../]
  [./bottom_z]
    type = DirichletBC
    boundary = 1
    variable = disp_z
    value = 0.0
  [../]
  [./sym_y]
    type = DirichletBC
    boundary = 3
    variable = disp_y
    value = 0.0
  [../]
  [./sym_x]
    type = DirichletBC
    boundary = 4
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
  end_time = 4.0
[]

[Outputs]
  csv = true
  file_base = penny_crack_out
  execute_on = timestep_end
  exodus = true
  [./console]
    type = Console
    output_linear = true
  [../]
[]
