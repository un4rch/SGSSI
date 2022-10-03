frecuencias="eaolsndruitcpmyqbhgfvjñzxkw"
frecuencias=frecuencias.upper()
texto_cifrado="RIJ AZKKZHC PIKCE XT ACKCUXJHX SZX, E NZ PEJXKE, PXGIK XFDKXNEQE RIPI RIPQEHCK ET OENRCNPI AXNAX ZJ RKCHXKCI AX CJAXDXJAXJRCE AX RTENX, E ACOXKXJRCE AXT RITEQIKERCIJCNPI OKXJHXDIDZTCNHE AX TE ACKXRRCIJ EJEKSZCNHE. AZKKZHC OZX ZJ OERHIK AX DKCPXK IKAXJ XJ XT DEDXT AX TE RTENX IQKXKE XJ REHETZJVE XJ GZTCI AX 1936. DXKI AZKKZHC, RIPI IRZKKX RIJ TEN DXKNIJETCAEAXN XJ TE MCNHIKCE, JI REVI AXT RCXTI. DXKNIJCOCREQE TE HKEACRCIJ KXvITZRCIJEKCE AX TE RTENX IQKXKE. NZ XJIKPX DIDZTEKCAEA XJHKX TE RTENX HKEQEGEAIKE, KXOTXGEAE XJ XT XJHCXKKI PZTHCHZACJEKCI XJ QEKRXTIJE XT 22 AX JIvCXPQKX AX 1936, PZXNHKE XNE CAXJHCOCRERCIJ. NZ PZXKHX OZX NCJ AZAE ZJ UITDX IQGXHCvI ET DKIRXNI KXvITZRCIJEKCI XJ PEKRME. NCJ AZKKZHC SZXAI PEN TCQKX XT REPCJI DEKE SZX XT XNHETCJCNPI, RIJ TE RIPDTCRCAEA AXT UIQCXKJI AXT OKXJHX DIDZTEK V AX TE ACKXRRCIJ EJEKSZCNHE, HXKPCJEKE XJ PEVI AX 1937 TE HEKXE AX TCSZCAEK TE KXvITZRCIJ, AXNPIKETCLEJAI E TE RTENX IQKXKE V OERCTCHEJAI RIJ XTTI XT DINHXKCIK HKCZJOI OKEJSZCNHE."
#texto_cifrado = texto_cifrado.upper() # No poner todo en mayusculas porque las "v" no estan cifradas

print(texto_cifrado + "\n")

letras = {}

for letra in frecuencias:
    letras[letra] = 0

for letra in texto_cifrado:
    if letra in letras:
        letras[letra] += 1

def get_value(elem): #Devolver valor de una clave
    return elem[1]

def get_keys(elem): #Devolver un array de las claves, por ser un array de tuplas
    array = []
    for item in elem:
        array.append(item[0])
    return array

letras_ordenadas = get_keys(sorted(letras.items(), key=get_value, reverse=True)) #ordenar keys en funcion de values

#for i in range(0,len(letras_ordenadas)):
#    print(letras_ordenadas[i] + " - " + frecuencias[i] + " - " + str(letras[letras_ordenadas[i]]))

texto_descifrado = texto_cifrado
cont = 0
for letra in texto_cifrado:
    if letra in frecuencias:
        texto_descifrado = texto_descifrado[:cont] + frecuencias[letras_ordenadas.index(letra)] + texto_descifrado[cont+1:]
    cont += 1

#print(texto_descifrado)

lista_cambios = { #En el examen rehacer esta lista después de la primera aproximación del descifrado deduciendo que letras pueden ser cuales
    "E": "e",
    "R": "d",
    "D": "l",
    "T": "s",
    "Q": "b",
    "O": "r",
    "S": "i",
    "P": "m",
    "N": "n",
    "L": "o",
    "B": "q",
    "U": "c",
    "A": "a",
    "C": "t",
    "G": "y",
    "M": "p",
    "I": "u",
    "Y": "f",
    "H": "j",
    "F": "g",
    "V": "h",
    "J": "z",
    "Ñ": "x"
}

for letra in lista_cambios:
    texto_descifrado = texto_descifrado.replace(letra, lista_cambios[letra])

relaciones = {}
cont=0
for letra in texto_descifrado:
    relaciones[letra]=texto_cifrado[cont]
    cont+=1
print(texto_descifrado + "\n")
relaciones = sorted(relaciones.items())
print("Relaciones: Cifrado --> Descifrado")
print("----------------------------------")
for relacion in relaciones:
    print("            " + relacion[1] + " --> " + relacion[0])
