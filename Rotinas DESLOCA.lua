
-- Input da estrutura, seguindo o padrão xi, yi, xf, yf, E, A, I (em cm, kN/cm², cm², cm^4)
local Estrutura = {
  --    xi,  yi,  xf,  yf,     E,  A,     I
  [1] = {0,   0,   0, 400, 20000, 60,  8000}, -- barra 1
  [2] = {0, 400, 600, 400, 20000, 80, 16000}  -- barra 2
}
-- TODO: Verificar se é melhor fazer [1] = {xi = 0, yi = 0, xf = 0, yf = 400, E = 20000, A = 60,  I = 8000} e depois referenciar usando barra.xi, barra.E, etc


-- Função que retorna o comprimento e a inclinação da barra
local function dimensoes(barra)

  local delta_x = barra[3] - barra[1]
  local delta_y = barra[4] - barra[2]

  local comprimento = math.sqrt(delta_x^2 + delta_y^2)
  
  local cosseno = delta_x/comprimento
  local seno = delta_y/comprimento
  
  return comprimento, cosseno, seno
 
end


-- Função que retorna a matriz espelhada
local function espelhada(matriz)
  
  local matriz_espelhada = matriz
  
  for i = 1, #matriz[1] do -- TODO: testar se #matriz[1] funciona, ou #matriz
    for j = 1, #matriz[1] do
     
      matriz_espelhada[j][i] = matriz[i][j]
     
    end
  end

  return matriz_espelhada
end


-- Função que retorna a multiplicação de matrizes
local function mult_matrizes(mat1, mat2, mat3)

 -- TODO: talvez usar módulo Lua Matrix https://github.com/davidm/lua-matrix

end

-- Função que retorna as matrizes de rigidez em coordenadas locais e globais de cada barra
local function matriz_de_rigidez(barra)
  
  local L, cosseno, seno = dimensoes(barra)
  
  -- Construção da matriz de rigidez em coordenadas locais
  local mat_rig_local = {} -- TODO: ver se precisa declarar cada linha como tabela também (num for)
  
  mat_rig_local[1][1] = barra[5]*barra[6]/L          -- E*A/L
  mat_rig_local[1][4] = -mat_rig_local[1][1]         -- -E*A/L
  mat_rig_local[1][2] = mat_rig_local[1][3] = mat_rig_local[1][5] =mat_rig_local[1][6] = 0   -- 0
  
  mat_rig_local[2][2] = 12*barra[5]*barra[7]/(L^3)   -- 12*E*I/L³
  mat_rig_local[2][3] = 6*barra[5]*barra[7]/(L^2)    -- 6*E*I/L²
  mat_rig_local[2][5] = -mat_rig_local[2][2]         -- -12*E*I/L³
  mat_rig_local[2][6] = mat_rig_local[2][3]          -- 6*E*I/L²
  mat_rig_local[2][4] = 0                            -- 0
  
  mat_rig_local[3][3] = 4*barra[5]*barra[7]/L        -- 4*E*I/L
  mat_rig_local[3][5] = -mat_rig_local[2][3]         -- -6*E*I/L²
  mat_rig_local[3][6] = mat_rig_local[3][3]/2        -- 2*E*I/L
  mat_rig_local[3][4] = 0                            -- 0
  
  mat_rig_local[4][4] = mat_rig_local[1][1]          -- E*A/L
  mat_rig_local[4][5] = mat_rig_local[4][6] = 0      -- 0
  
  mat_rig_local[5][5] = mat_rig_local[2][2]          -- 12*E*I/L³
  mat_rig_local[5][6] = mat_rig_local[3][5]          -- -6*E*I/L²
  
  mat_rig_local[6][6] = mat_rig_local[3][3]          -- 4*E*I/L
  
  mat_rig_local = espelhada(mat_rig_local) -- Espelhamento da matriz de rigidez em coordenadas locais
  
  -- Construção da matriz de rotação
  local mat_rot = {}
  
  mat_rot[1][1] = mat_rot[2][2] = mat_rot[4][4] = mat_rot[5][5] = cosseno
  mat_rot[1][2] = mat_rot[4][5] = seno
  mat_rot[2][1] = mat_rot[5][4] = -seno
  mat_rot[3][3] = mat_rot[6][6] = 1
  for i = 1, 6 do -- preenchimento automático dos vazios com 0
    for j = 1, 6 do
      if mat_rot[i][j] = nil then mat_rot[i][j] = 0 end
    end
  end
  
  -- Construção da matriz de rotação transposta
  local mat_rot_t = mat_rot
  
  mat_rot_t[1][2] = mat_rot_t[4][5] = -seno
  mat_rot_t[2][1] = mat_rot_t[5][4] = seno
  
  -- Construção da matriz de rigidez em coordenadas globais
  local mat_rig_global = mult_matrizes(mat_rot_t, mat_rig_local, mat_rot) -- TODO: ver se é melhor não fazer essa função e programar a matriz manualmente ([1][1] = B*c² + D*s², etc)
  
  return = mat_rig_local, mat_rig_global
end











