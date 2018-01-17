
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


-- Função que retorna as matrizes de rigidez em coordenadas locais e globais de cada barra
local function matriz_de_rigidez(barra)
  
  -- Obtenção das propriedades da barra
  local E, A, I = barra[5], barra[6], barra[7]
  local L, C, S = dimensoes(barra)
  
  -- Coeficientes de rigidez das matrizes de rigidez
  local k1 = E*A/L
  local k2 = 12*E*I/(L^3)
  local k3 = 6*E*I/(L^2)
  local k4 = 4*E*I/L
  local k5 = 2*E*I/L
  
  -- Construção da matriz de rigidez em coordenadas locais
  local mat_rig_local = {
    { k1,  0,  0,-k1,  0,  0},
    {  0, k2, k3,  0,-k2, k3},
    {  0, k3, k4,  0,-k3, k5},
    {-k1,  0,  0, k1,  0,  0},
    {  0,-k2,-k3,  0, k2,-k3},
    {  0, k3, k5,  0,-k3, k4}
  }
  
  -- Construção da matriz de rotação -- TODO: talvez não precise, mas é informação
  local mat_rot = {
    { C, S, 0, 0, 0, 0},
    {-S, C, 0, 0, 0, 0},
    { 0, 0, 1, 0, 0, 0},
    { 0, 0, 0, C, S, 0},
    { 0, 0, 0,-S, C, 0},
    { 0, 0, 0, 0, 0, 1}
  }
  
  -- Construção da matriz de rotação transposta -- TODO: talvez não precise, mas é informação
  local mat_rot_t = {
    { C,-S, 0, 0, 0, 0},
    { S, C, 0, 0, 0, 0},
    { 0, 0, 1, 0, 0, 0},
    { 0, 0, 0, C,-S, 0},
    { 0, 0, 0, S, C, 0},
    { 0, 0, 0, 0, 0, 1}
  }
  
  -- Construção da matriz de rigidez em coordenadas globais
  local mat_rig_global = {
    {  k1*C^2+k2*S^2,    (k1-k2)*C*S, -k3*S, -k1*C^2-k2*S^2,    (k2-k1)*C*S, -k3*S},
    {    (k1-k2)*C*S,  k1*S^2+k2*C^2,  k3*C,    (k2-k1)*C*S, -k1*S^2-k2*C^2,  k3*C},
    {          -k3*S,           k3*C,    k4,           k3*S,          -k3*C,    k5},
    { -k1*C^2-k2*S^2,    (k2-k1)*C*S,  k3*S,  k1*C^2+k2*S^2,    (k1-k2)*C*S,  k3*S},
    {    (k2-k1)*C*S, -k1*S^2-k2*C^2, -k3*C,    (k1-k2)*C*S,  k1*S^2+k2*C^2, -k3*C},
    {          -k3*S,           k3*C,    k5,           k3*S,          -k3*C,    k4}
  }
  
  return mat_rig_local, mat_rig_global
end


-- Função que analisa a estrutura numerando os nós -- TODO: talvez colocar nós como variáveis globais
local function numerar_nos()

  local qtd_barras = #Estrutura
  if qtd_barras < 1 then error("Insira pelo menos 1 barra na estrutura!") end
  
  local nos = {}
  local qtd_nos = 2
  
  -- Nós inicias, da primeira barra                  --  xi, yi, xf, yf
  if Estrutura[1][1] == Estrutura[1][3] and Estrutura[1][2] == Estrutura[1][4] then error("A barra 1 é um ponto!") end
  nos[1] = {Estrutura[1][1], Estrutura[1][2]}
  nos[2] = {Estrutura[1][3], Estrutura[1][4]}
  
  -- Análises dos nós seguintes
  if qtd_barras > 1 then
    for i = 2, qtd_barras do
      
      if Estrutura[i][1] == Estrutura[i][3] and Estrutura[i][2] == Estrutura[i][4] then error("A barra " .. i .. " é um ponto!") end
      
      for j = 1, #nos do
        
        if Estrutura[i][1] == nos[j][1] and Estrutura[i][2] == nos[j][2] then -- sobreposição
          
        end
        
        if Estrutura[i][3] == nos[j][1] and Estrutura[i][4] == nos[j][2] then -- sobreposição
          
        end
        
      end
      
      
      nos[i] = {Estrutura[i][1], Estrutura[i][2]}
      
      
    end
  end
  
end


-- Função para erredondar número num em n casas decimais
local function arred(num, n)
  local mult = 10^(n or 0)
  return math.floor(num * mult + 0.5)/mult
end

-- ##################################################################################################################
-- TESTES
-- ##################################################################################################################

local L_TESTE, cos_TESTE, sen_TESTE = dimensoes(Estrutura[1])
local mat_rig_local_TESTE, mat_rig_global_TESTE = matriz_de_rigidez(Estrutura[1])
print("\nBarra 1 ###################################################")

print(string.format("\nL = %d, cos = %d, sen = %d", L_TESTE, cos_TESTE, sen_TESTE)) -- OK!
--for i = 1, 6 do print(mat_rig_local_TESTE[i]) end -- OK!
--for i = 1, 6 do print(mat_rig_global_TESTE[i]) end -- OK!
local maior_num_digit = string.len(string.format("%d", arred(mat_rig_local_TESTE[1][1], 0)))
for i = 1, 6 do
  for j = 1, 6 do
    if string.len(tostring(arred(mat_rig_local_TESTE[i][j], 0))) > maior_num_digit then
      maior_num_digit = string.len(string.format("%d", arred(mat_rig_local_TESTE[i][j], 0)))
    end
  end
end

print("\nMatriz de rigidez em coordenadas locais:")
for i = 1, 6 do
  local str = ""
  for j = 1, 6 do
    
    local espacos = maior_num_digit - string.len(string.format("%d", arred(mat_rig_local_TESTE[i][j], 0)))
    if espacos > 0 then
      for i = 1, espacos do
        str = str .. " "
      end
    end
    str = str .. string.format("%d", arred(mat_rig_local_TESTE[i][j], 0)) .. " "
  
  end
  print(str)
end

local maior_num_digit = string.len(string.format("%d", arred(mat_rig_global_TESTE[1][1], 0)))
for i = 1, 6 do
  for j = 1, 6 do
    if string.len(tostring(arred(mat_rig_global_TESTE[i][j], 0))) > maior_num_digit then
      maior_num_digit = string.len(string.format("%d", arred(mat_rig_global_TESTE[i][j], 0)))
    end
  end
end

print("\nMatriz de rigidez em coordenadas globais:")
for i = 1, 6 do
  local str = ""
  for j = 1, 6 do
    
    local espacos = maior_num_digit - string.len(string.format("%d", arred(mat_rig_global_TESTE[i][j], 0)))
    if espacos > 0 then
      for i = 1, espacos do
        str = str .. " "
      end
    end
    str = str .. string.format("%d", arred(mat_rig_global_TESTE[i][j], 0)) .. " "
  
  end
  print(str)
end


L_TESTE, cos_TESTE, sen_TESTE = dimensoes(Estrutura[2])
mat_rig_local_TESTE, mat_rig_global_TESTE = matriz_de_rigidez(Estrutura[2])
print("\nBarra 2 ###################################################")

print(string.format("L = %d, cos = %d, sen = %d \n", L_TESTE, cos_TESTE, sen_TESTE)) -- OK!
--for i = 1, 6 do print(mat_rig_local_TESTE[i]) end -- OK!
--for i = 1, 6 do print(mat_rig_global_TESTE[i]) end -- OK!

local maior_num_digit = string.len(string.format("%d", arred(mat_rig_local_TESTE[1][1], 0)))
for i = 1, 6 do
  for j = 1, 6 do
    if string.len(tostring(arred(mat_rig_local_TESTE[i][j], 0))) > maior_num_digit then
      maior_num_digit = string.len(string.format("%d", arred(mat_rig_local_TESTE[i][j], 0)))
    end
  end
end

print("\nMatriz de rigidez em coordenadas locais:")
for i = 1, 6 do
  local str = ""
  for j = 1, 6 do
    
    local espacos = maior_num_digit - string.len(string.format("%d", arred(mat_rig_local_TESTE[i][j], 0)))
    if espacos > 0 then
      for i = 1, espacos do
        str = str .. " "
      end
    end
    str = str .. string.format("%d", arred(mat_rig_local_TESTE[i][j], 0)) .. " "
  
  end
  print(str)
end

local maior_num_digit = string.len(string.format("%d", arred(mat_rig_global_TESTE[1][1], 0)))
for i = 1, 6 do
  for j = 1, 6 do
    if string.len(tostring(arred(mat_rig_global_TESTE[i][j], 0))) > maior_num_digit then
      maior_num_digit = string.len(string.format("%d", arred(mat_rig_global_TESTE[i][j], 0)))
    end
  end
end

print("\nMatriz de rigidez em coordenadas globais:")
for i = 1, 6 do
  local str = ""
  for j = 1, 6 do
    
    local espacos = maior_num_digit - string.len(string.format("%d", arred(mat_rig_global_TESTE[i][j], 0)))
    if espacos > 0 then
      for i = 1, espacos do
        str = str .. " "
      end
    end
    str = str .. string.format("%d", arred(mat_rig_global_TESTE[i][j], 0)) .. " "
  
  end
  print(str)
end


--numerar_nos()
