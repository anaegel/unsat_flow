-- config for modelling a drainage trench with constant groundwater flow

Trench2D_rho = 998.23
Trench2D_g = -9.81
Trench2D_rhog = (-1.0)*Trench2D_rho*Trench2D_g

local trench2D = 
{ 
  -- The domain specific setup
  domain = 
  {
    dim = 2,
    grid = "grids/trench2D.ugx",
    numRefs = ARGS.numRefs,
    numPreRefs = ARGS.numPreRefs,
  },

  -- list of non-linear models => translated to functions
  parameter = {  
    { uid = "@Silt",
      type = "vanGenuchten",
      thetaS = 0.396, thetaR = 0.131,
      alpha = 0.423*Trench2D_rhog, n = 2.06, Ksat= 4.745e-6},--4.96e-1 }, 
    
    { uid = "@Clay",  -- modified n
      type = "vanGenuchten",
      alpha = 0.152*Trench2D_rhog, n = 3.06,  
      thetaS = 0.446, thetaR = 0.1, 
      Ksat= 8.2e-4 * 1e-3,},  --KSat= kappa/mu*rh0*g   <=> kappa = Ksat*mu/(rho*g) 
  },
  
  paramTable = { 
    ["DrainageTime"] = 1.0, 
  },

  var ={
    CharacteristicTime = 1.0,
    RiseTime = 1.0,
  },

  flow = 
  {
    type = "haline",
    cmp = {"p", "c"},

    gravity = Trench2D_g,    -- [ m s^{-2}�] ("standard", "no" or numeric value) 
    density =           
    { type = "linear",    -- density function ["linear", "exp", "ideal"]
      min = Trench2D_rho, -- [ kg m^{-3} ] water density
      max = 1195.0,       -- [ kg m^{-3} ] saltwater density
      w_max = 1,
    },  
    
    viscosity = 
    { type = "const",      -- viscosity function ["const", "real"] 
      mu0 = 1e-3        -- [ kg m^{-3} ]  
    },
  },
   medium = 
   {
      {   subsets = {"Inner"}, 
          porosity = 0.35,
          saturation = 
          { type = "vanGenuchten",
            value = "@Silt",
          },
          conductivity =
          { type  = "vanGenuchten",
            value   = "@Silt",
          },
          diffusion   = 18.8571e-6,   -- constant
          permeability  = 1.019368e-9 / Trench2D_rhog,  -- constant
      },
  },

  initial= 
   {
       { cmp = "p", value = "Trench2DPressureStart"},
       { cmp = "c", value = 0}
   },

  boundary = 
  {
     {cmp = "p", type = "dirichlet", bnd = "Trench", value = "Trench2DDrainagePressureBoundary"},
     {cmp = "p", type = "dirichlet", bnd = "Aquifer", value = "Trench2DAquiferBoundary" },
     {cmp = "c", type = "dirichlet", bnd = "Trench", value = 1},
     {cmp = "c", type = "dirichlet", bnd = "Aquifer", value = 0},


  },

  solver =
  {
      type = "newton",
      lineSearch = {			   		-- ["standard", "none"]
          type = "standard",
          maxSteps		= 10,		-- maximum number of line search steps
          lambdaStart		= 1,		-- start value for scaling parameter
          lambdaReduce	= 0.5,		-- reduction factor for scaling parameter
          acceptBest 		= true,		-- check for best solution if true
          checkAll		= false		-- check all maxSteps steps if true 
      },

      convCheck = {
          type		= "standard",
          iterations	= 128,			-- number of iterations
          absolute	= 1e-8,			-- absolut value of defact to be reached; usually 1e-6 - 1e-9
          reduction	= 1e-7,		-- reduction factor of defect to be reached; usually 1e-6 - 1e-7
          verbose		= true			-- print convergence rates if true
      },
      
      linSolver =
      {
          type = "bicgstab",			-- linear solver type ["bicgstab", "cg", "linear"]
          precond = 
          {	
              type 		= "gmg",	-- preconditioner ["gmg", "ilu", "ilut", "jac", "gs", "sgs"]
              smoother 	= {type = "ilu", overlap = true},	-- gmg-smoother ["ilu", "ilut", "jac", "gs", "sgs"]
              cycle		= "V",		-- gmg-cycle ["V", "F", "W"]
              preSmooth	= 3,		-- number presmoothing steps
              postSmooth 	= 3,		-- number postsmoothing steps
              rap			= true,		-- comutes RAP-product instead of assembling if true 
              baseLevel	= ARGS.numPreRefs, -- gmg - baselevel
              
          },
          convCheck = {
              type		= "standard",
              iterations	= 30,		-- number of iterations
              absolute	= 0.5e-8,	-- absolut value of defact to be reached; usually 1e-8 - 1e-10 (must be stricter / less than in newton section)
              reduction	= 1e-7,		-- reduction factor of defect to be reached; usually 1e-7 - 1e-8 (must be stricter / less than in newton section)
              verbose		= true,		-- print convergence rates if true
          }
      }
  },

  time = 
  {
    control = "limex",
    start   = 0.0,    -- [s] start time point
    stop  = 20.0,  -- [s] end time point  -- 10,000 years
    dt  = 0.01, -- [s] initial time step
    dtmin = 1e-8, -- [s] minimal time step
    dtmax = 100, -- [s] maximal time step  -- 100.0 years
    dtred = 0.5,    -- [1] reduction factor for time step
    tol   = 1e-3
  },
}


function Trench2DDrainagePressureBoundaryTime(x, y, t, tD)
  if (t <= tD) then
    return true, (2.2*t / tD - 2.0) * trench2D.flow.density.max * trench2D.flow.gravity
  else
    return true, 0.2 * trench2D.flow.density.max * trench2D.flow.gravity
  end
end

function Trench2DDrainagePressureBoundary(x, y, t)
  return Trench2DDrainagePressureBoundaryTime(x, y, t, trench2D.paramTable["DrainageTime"])  
end

function Trench2DAquiferBoundary(x, y, t)
  temp = (1.0 - y) * Trench2D_rhog
  return true, temp
end

function Trench2DPressureStart(x, y, t)
  return (1.0 - y) * Trench2D_rhog
end

return trench2D

