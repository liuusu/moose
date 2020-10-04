[GlobalParams]
  order = FIRST
  family = LAGRANGE
[]

[XFEM]
  geometric_cut_userobjects = 'cut_mesh'
  qrule = volfrac
  output_cut_plane = true
[]

[Mesh]
  file = ellipse.e
  displacements = 'disp_x disp_y disp_z'
[]

[UserObjects]
  [./cut_mesh]
    type = MeshCut3DUserObject
    mesh_file = mesh_ellipse_crack2.xda
    size_control = 1  # was 0.125
    n_step_growth = 1
    growth_dir_method = 'max_hoop_stress'
    function_x = growth_func_x
    function_y = growth_func_y
    function_z = growth_func_z
    function_v = growth_func_v
    crack_front_nodes = '17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1'
  [../]
[]

[Functions]
  [./growth_func_x]
    type = ParsedFunction
    value = x
  [../]
  [./growth_func_y]
    type = ParsedFunction
    value = y
  [../]
  [./growth_func_z]
    type = ParsedFunction
    value = z
  [../]
  [./growth_func_v]
    type = ParsedFunction
    value = 0.011
  [../]
[]

[Variables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./disp_z]
  [../]
[]

[AuxVariables]
  [./stress_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_yy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_zz]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vonmises]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./SED]
   order = CONSTANT
    family = MONOMIAL
  [../]
[]

[DomainIntegral]
  integrals = 'Jintegral InteractionIntegralKI InteractionIntegralKII'
  displacements = 'disp_x disp_y disp_z'
  crack_front_points_provider = cut_mesh
  number_points_from_provider = 17
  crack_end_direction_method = CrackTangentVector
  crack_tangent_vector_end_1 = '1 0 0'
  crack_tangent_vector_end_2 = '-1 0 0'
  crack_direction_method = CurvedCrackFront
  radius_inner = '0.01'
  radius_outer = '0.05'
  poissons_ratio = 0.3
  youngs_modulus = 207000
  block = 1
  incremental = true
  solid_mechanics = true
[]

[SolidMechanics]
  [./solid]
    disp_x = disp_x
    disp_y = disp_y
    disp_z = disp_z
    use_displaced_mesh = true
  [../]
[]

[AuxKernels]
  [./stress_xx]
    type = MaterialTensorAux
    tensor = stress
    variable = stress_xx
    index = 0
    execute_on = timestep_end
  [../]
  [./stress_yy]
    type = MaterialTensorAux
    tensor = stress
    variable = stress_yy
    index = 1
    execute_on = timestep_end
  [../]
  [./stress_zz]
    type = MaterialTensorAux
    tensor = stress
    variable = stress_zz
    index = 2
    execute_on = timestep_end
  [../]
  [./vonmises]
    type = MaterialTensorAux
    tensor = stress
    variable = vonmises
    quantity = vonmises
    execute_on = timestep_end
  [../]
  [./SED]
    type = MaterialRealAux
    variable = SED
    property = strain_energy_density
    execute_on = timestep_end
    block = 1
  [../]
[]

[BCs]
  [./top_z]
    type = NeumannBC
    boundary = top
    variable = disp_z
    value = 1
  [../]
  [./bottom_z]
    type = NeumannBC
    boundary = bottom
    variable = disp_z
    value = -1
  [../]
  [./sym]
    type = DirichletBC
    boundary = sym
    variable = disp_x
    value = 0.0
  [../]
  [./fix_x]
    type = DirichletBC
    boundary = fix
    variable = disp_x
    value = 0.0
  [../]
  [./fix_y]
    type = DirichletBC
    boundary = fix
    variable = disp_y
    value = 0.0
  [../]
  [./fix_z]
    type = DirichletBC
    boundary = fix
    variable = disp_z
    value = 0.0
  [../]
  [./constrain]
    type = DirichletBC
    boundary = constrain
    variable = disp_z
    value = 0.0
  [../]
[]

[Materials]
  [./linelast]
    type = Elastic
    block = 1
    disp_x = disp_x
    disp_y = disp_y
    disp_z = disp_z
    poissons_ratio = 0.3
    youngs_modulus = 207000
    compute_JIntegral = true
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
  csv = true
  file_base = out/ellipse
  execute_on = timestep_end
  exodus = true
  [./console]
    type = Console
    output_linear = true
  [../]
[]
