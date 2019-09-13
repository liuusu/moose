[GlobalParams]
  order = FIRST
  family = LAGRANGE
  displacements = 'disp_x disp_y disp_z'
[]

[XFEM]
  geometric_cut_userobjects = 'cut_mesh'
  qrule = volfrac
  output_cut_plane = true
[]

[Mesh]
  file = clad_mesh.e
[]

[UserObjects]
  [./cut_mesh]
    type = MeshCut3DUserObject
    mesh_file = clad_cut.xda
    size_control = 0.00051282
    n_step_growth = 1
    growth_type = 'function'
    function_x = growth_func_x
    function_y = growth_func_y
    function_z = growth_func_z
  [../]
[]

[Functions]
  [./growth_func_x]
    type = ParsedFunction
    value = 0
  [../]
  [./growth_func_y]
    type = ParsedFunction
    value = 0
  [../]
  [./growth_func_z]
    type = ParsedFunction
    value = z
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

[Functions]
  [./top_trac_y]
    type = ConstantFunction
    value = 10
  [../]
[]


[BCs]
  [./Pressure]
    [./inner]
      boundary = 103
      function = 1
      displacements = 'disp_x disp_y disp_z'
    [../]
  [../]
#  [./inner]
#    type = DirichletBC
#    boundary = 103
#    variable = pressure
#    value = 1000000
#  [../]
  [./bottom_x]
    type = PresetBC
    boundary = 101
    variable = disp_x
    value = 0.0
  [../]
  [./bottom_y]
    type = PresetBC
    boundary = 101
    variable = disp_y
    value = 0.0
  [../]
  [./bottom_z]
    type = PresetBC
    boundary = 101
    variable = disp_z
    value = 0.0
  [../]
  [./top_x]
    type = PresetBC
    boundary = 102
    variable = disp_x
    value = 0.0
  [../]
  [./top_y]
    type = PresetBC
    boundary = 102
    variable = disp_y
    value = 0.0
  [../]
  [./top_z]
    type = PresetBC
    boundary = 102
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
  # petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  # petsc_options_value = '201                hypre    boomeramg      8'

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

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
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-8

# time control
  start_time = 0.0
  dt = 1.0
  end_time = 18.0
  max_xfem_update = 1
[]

[Outputs]
  file_base = clad
  execute_on = 'timestep_end'
  exodus = true
  [./console]
    type = Console
    output_linear = true
  [../]
[]
