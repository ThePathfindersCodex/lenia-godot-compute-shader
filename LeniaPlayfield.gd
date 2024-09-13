extends Resource
class_name LeniaPlayfield

@export var name :String= "UNNAMED PLAYFIELD NAME"
@export var amplitudes :Array[float]= [1.0/2.0, 7.0/12.0, 3.0/4.0, 1.0]
@export var k_radius :int= 36
@export var frequency_scale :int= 100
@export var growth_m :float= 0.23
@export var growth_s :float= 0.019

@export var pattern = [[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.04,1,1,0.38],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.52,0.99,1,1,1,0.48,0,0,0,0,1,1,1,1,1,1,1,0.92],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.23,0.99,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,0.06],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.64,1,1,1,1,1,1,1,0,0,0,0.97,1,1,1,1,1,1,1,0,0,0,0,0,0.1],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.96,1,1,1,1,1,1,1,0,0,0,0.86,0.99,1,1,1,0.99,0.82,0.49,0,0,0,0.01,1,1,1,1,0.37],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0.99,0.93,0.94,0.98,0.98,0.88,0.63,0.34,0.07,0,0,0,0.99,1,1,1,1,1,0.3],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.41,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0.93,0.68,0.44,0.23,0.05,0,0.26,0.85,1,1,1,1,1,1],
[0,0,0,0,0,0,0,0.2,0.42,0.55,0.18,0,0,0.22,0.55,0.69,0.76,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0.99,0.88,0.62,0.35,0.35,0.71,1,1,1,1,1,1],
[0,0,0,0,0,0,0.67,1,1,1,1,1,0.7,0.72,0.75,0.67,0.63,1,1,1,1,1,1,1,0.58,0.85,0.97,1,1,1,1,1,1,1,0.9,0.67,0.75,0.99,1,1,1,1,1],
[0,0,0,0,0,0.66,1,1,1,1,1,1,1,0.89,0.91,1,1,1,1,1,1,0.06,0,0,0,0,0,0,0,0,0,0,0.62,1,1,1,0.97,0.97,1,1,1,1,1],
[0,0,0,0,0,0.93,1,1,1,1,1,1,1,1,1,1,1,1,0.9,0.07,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0.93,0.88,0.9,0.91],
[0,0,0,0,0,0.99,1,1,1,1,1,1,1,1,1,1,1,0.02,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0.71],
[0,0,0,0,0,0.92,1,1,1,1,1,1,1,1,1,0.79,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1],
[0,0,0,0,0,0,1,1,1,1,1,1,1,1,0.86,0,0,0,0,0,0,0,0,0,0.49,1,1,1,0.99,0.5,0,0,0,0,0,0,0,1,1,1,1,0.19,0,0.39,1,1,0.98,0.58],
[0,0,0,0,0,0,0,0.01,0.16,0.78,1,1,1,0.76,0,0,0,0,0,0,0,0.07,0.67,1,1,1,1,1,1,1,1,0.77,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0.67],
[0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0.4,0.92,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0.2],
[0,0,0,0,0,0,0,0,0.99,1,1,1,0,0,0,0,0,0,0.02,0.58,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0.49],
[0,0,0,0.53,1,0,0,0,1,1,1,0,0,0,0,0,0,0.01,0.67,1,1,1,1,1,1,1,0.74,0.7,1,1,1,1,1,1,0.82,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0.37],
[0,0.14,1,1,1,1,0.91,0.89,1,1,1,0,0,0,0,0,0.03,0.72,1,1,1,1,1,1,1,0.5,0,0,0,0.52,1,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,0.97,0.11],
[0,1,1,1,1,1,1,0.99,1,1,0.12,0,0,0,0,0,0.95,1,1,1,1,1,1,1,0.74,0,0,0,0,0,0.75,1,1,1,1,0.32,0,0,0,0,0.41,1,1,1,1,1,1,1,0.57],
[0.51,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,0.57,0,0,0,0.65,1,1,1,1,0.42,0,0,0,0,0.11,1,1,1,0.66,0.78,0.67,0.08],
[0.81,1,1,1,1,1,1,1,1,1,0,0,0,0,0.38,1,1,1,1,1,0.9,1,1,1,1,1,1,1,0.83,0.71,0.84,1,1,1,1,0.54,0,0,0,0,0,1,1,1,0.58,0.54,0.23],
[0.45,1,1,1,1,1,0.96,1,1,1,0,0,0,0,1,1,1,1,1,0.6,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0.67,0,0,0,0,0,1,1,1,0.65,0.55,0.21],
[0,1,1,1,1,0.77,0.68,1,1,0.58,0,0,0,0,1,1,1,1,0.59,0,0,0.91,1,1,1,1,1,1,1,1,1,1,1,1,1,0.82,0,0,0,0,0,0.75,1,1,0.65,0.65,0.5],
[0,0.26,1,1,0.72,0.3,0.38,0.98,1,0.06,0,0,0,0,1,1,1,1,0.22,0,0,0.63,1,1,1,1,1,1,1,1,1,1,1,1,1,0.94,0.1,0,0,0,0,0.81,1,1,0.7,0.89,1,1,0.85],
[0,0,0,0,0,0,0.21,0.97,1,0,0,0,0,0,1,1,1,1,0.15,0,0,0.41,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0.2,0,0,0,0,0.93,1,1,1,1,1,1,1,0.73],
[0,0,0,0,0,0,0.12,0.94,1,0,0,0,0,0,0.79,1,1,1,0.41,0,0,0.38,1,1,1,1,1,1,1,1,0.14,0.85,1,1,1,1,0.19,0,0,0,0,1,1,1,1,1,1,1,1,1,0.41],
[0,0,0,0,0,0,0.05,0.8,1,0.53,0,0,0,0,0.37,1,1,1,0.95,0.14,0,0.55,1,1,1,1,1,1,0.75,0.01,0,0.82,1,1,1,1,0.16,0,0,0,0,1,1,1,1,1,1,1,1,1,0.73],
[0,0,0,0,0.13,0.18,0.13,0.61,1,1,0,0,0,0,0,1,1,1,1,1,0.35,0.64,1,1,1,1,1,0.46,0,0,0,0.61,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0.8],
[0,0,0.69,1,1,0.79,0.47,0.62,1,1,0.26,0,0,0,0,0.56,1,1,1,1,1,1,1,1,1,1,0.65,0,0,0,0,0.93,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0.63],
[0,0.18,1,1,1,1,0.93,0.84,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0.74,0,0,0,0.04,0.82,1,1,1,1,0.17,0,0,0,0,0,1,1,1,1,1,1,1,1,0.85],
[0,0.45,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0.74,0.82,1,1,1,1,1,0.96,0,0,0,0,0,1,1,1,1,0,0.34,0.98,0.96,0.58],
[0,0.39,1,1,1,1,1,1,1,1,1,0.99,0,0,0,0,0,0,0.46,0.85,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1],
[0,0,1,1,1,1,1,1,0.98,1,1,1,0,0,0,0,0,0,0,0.03,0.44,0.78,1,1,1,1,1,1,1,1,1,1,1,0.05,0,0,0,0,0,1,1,1,0.02],
[0,0,0.93,1,1,1,1,1,0.88,0.99,1,1,1,0,0,0,0,0,0,0,0,0,0.22,0.52,0.85,1,1,1,1,1,1,0.71,0,0,0,0,0,0,0.99,1,1,0.92],
[0,0,0,0.52,1,1,1,0.91,0,0.54,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0.26,0.73,0.83,0.41,0.18,0,0,0,0,0,0,0,0.38,1,1,1,0.95,0.96,1,1],
[0,0,0,0,0,0,0,0,0,0,0.51,1,1,1,1,0.15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0.99,1,1,1,1,1],
[0,0,0,0,0,0,0,0,0,0,0,0.24,1,1,1,1,0.61,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0.99,0.88,0.98,1,1,1,1,1],
[0,0,0,0,0,0,0,0,0,0,0.44,1,1,1,1,1,1,1,0.06,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.44,1,1,0.96,0.59,0.63,0.98,1,1,1,1,1],
[0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,0.45,0.14,0,0,0,0,0,0,0,0,0,0.38,1,1,1,1,0.88,0.39,0.19,0.5,1,1,1,1,1,1],
[0,0,0,0,0,0,0,0,0.87,1,1,1,1,1,1,0.94,1,1,1,1,1,1,1,1,0.94,0.15,0,0,0.08,1,1,1,1,1,0.93,0.54,0.16,0,0,0.48,1,1,1,1,1,0.64],
[0,0,0,0,0,0,0,0,0.88,1,1,1,1,1,1,0.92,0.74,0.87,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0.77,0.42,0.13,0,0,0,0,1,1,1,1,0.37],
[0,0,0,0,0,0,0,0,0.69,1,1,1,1,1,1,0.88,0.7,0.74,0.78,0.72,0.86,1,1,1,1,1,1,1,1,1,0.99,0.93,0.87,0.76,0.6,0.43,0.28],
[0,0,0,0,0,0,0,0,0,0.93,1,1,1,1,1,0.31,0.26,0.44,0.67,0.83,1,1,1,1,1,1,1,1,1,0.85,0.86,0.97,1,1,1,1,0.97],
[0,0,0,0,0,0,0,0,0,0,0.69,0.81,0.8,0.65,0,0,0,0,0.48,1,1,1,1,1,1,1,0.09,0,0,0.2,0.98,1,1,1,1,1,1,0.47],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.4,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,0.59],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.49,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,0.07],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.86,1,1,1,1,1,0.92,0,0,0,0,0.07,1,1,1,1,1,0.27],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.21,0.86,1,1,1,0.89,0,0,0,0,0,0,0,0.31,0.85,0.43],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.56,0.66,0.44]]

