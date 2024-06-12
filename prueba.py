#Algoritmo de prueba para speech analyzer con expresiones regulares
#Lee una llamada de un call center y analiza las palabras clave (tokens)
#establecidas en una expresion regular

'''
Ejemplo: 
Expresion regular malo: malo|horrible|pésimo
Expresion regular bueno: bueno|excelente|bien|amable
Expresion regular normal: normal|regular|aceptable|ok

Ejemplo de llamada:
Buen dia, Desde ayer que no puedo consultar mi saldo.
Claro, tres millones doscientos sesenta mil cero sesenta y otro.
En año de mi nacimiento es mil novecientos noventa y seis.
No, muchas gracias. Ustes ha sido muy amable.
Hasta luego.
'''

import re

def main():
    #Expresiones regulares
    malo = re.compile(r'malo|horrible|pésimo')
    bueno = re.compile(r'bueno|excelente|bien|amable|gracias')
    #Llamada separada por saltos de linea (para simular la lectura de un archivo)
    llamada =  '''Buen dia, Desde ayer que no puedo consultar mi saldo.
Claro, tres millones doscientos sesenta mil cero sesenta y otro.
En año de mi nacimiento es mil novecientos noventa y seis.
No, muchas gracias. Ustes ha sido muy amable.
Hasta luego.'''

    #Analizar
    puntosBueno = 0
    puntosMalo = 0
    #Se lee linea a linea, considerando que a medida que la linea avanza, se añade el punto multiplicado
    #por el numero de linea.
    #Esto es porque una llamada puede tener muchos puntos malos al principio pero al final solucionar el problema
    #y ser considerada buena o viceversa.

    for i, linea in enumerate(llamada.split('\n')):
        puntosBueno += len(re.findall(bueno, linea)) * (i+1)
        puntosMalo += len(re.findall(malo, linea)) * (i+1)
    
    print(f'Puntos buenos: {puntosBueno}')
    print(f'Puntos malos: {puntosMalo}')

    if puntosBueno > puntosMalo:
        print('La llamada fue buena')
    elif puntosBueno < puntosMalo:
        print('La llamada fue mala')
    
main()
#Output:
#Puntos buenos: 8
#Puntos malos: 0
#La llamada fue buena