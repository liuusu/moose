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
  type = GeneratedMesh
  dim = 3
  nx = 7
  ny = 7
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
  [./cut_mesh]
    type = MeshCut3DUserObject
    mesh_file = mesh_penny_crack.xda
    size_control = 1
    n_step_growth = 1
    growth_dir_method = 'max_hoop_stress'
    function_x = growth_func_x
    function_y = growth_func_y
    function_z = growth_func_z
    function_v = growth_func_v
    crack_front_nodes = '7 6 5 4 3 2 1'
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
    value = 0.15   # was 1.25
  [../]
[]

[DomainIntegral]
  integrals = 'Jintegral InteractionIntegralKI InteractionIntegralKII'
  displacements = 'disp_x disp_y disp_z'
  crack_front_points_provider = cut_mesh
  number_points_from_provider = 7
  crack_end_direction_method = CrackTangentVector
  crack_tangent_vector_end_1 = '1 0 0'
  crack_tangent_vector_end_2 = '0 -1 0'
  crack_direction_method = CurvedCrackFront
  intersecting_boundary = '1 4' #It would be ideal to use this, but can't use with XFEM yet
  radius_inner = '0.1'
  radius_outer = '0.3'
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

[Functions]
  [./top_trac_x]
    type = ConstantFunction
    value = -5
  [../]
  [./top_trac_y]
    type = ConstantFunction
    value = -5
  [../]
  [./top_trac_z]
    type = ConstantFunction
    value = 10
  [../]
[]

[BCs]
  [./top_x]
    type = FunctionNeumannBC
    boundary = front
    variable = disp_x
    function = top_trac_x
  [../]
  [./top_y]
    type = FunctionNeumannBC
    boundary = front
    variable = disp_y
    function = top_trac_y
  [../]
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
    block = 0
  [../]
  [./stress]
    type = ComputeFiniteStrainElasticStress
    block = 0
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
  end_time = 3.0
[]

[Outputs]
  csv = true
  file_base = penny_crack_mhs_out
  execute_on = timestep_end
  exodus = true
  [./console]
    type = Console
    output_linear = true
  [../]
[]
