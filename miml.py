
import numpy as np

# Function for finding probability of ybi given xbi,w
# Equation one from Paper
# w --> d x c
def predict(y,x,w):
	#computing soft max function
	sum=0.0
	for i in range(0,len(w)):
		sum+=np.exp(w[i].transpose().dot(x))
	return (np.exp(w[y].transpose().dot(x))) / sum

# Function for mstep updating all vectors of w
def mstep(w,b,prob):
	for i in range(0,len(w)):
		sum=np.zeros([len(b[0][0]),1])
		for bag in b:
			x=bag
			for j,instance in enumerate(x):
				sum+=(instance*prob[j][i]-predict(i,inst,w)*instance)
		w[i]+=sum

# Function for estep for getting the probabilities
def estep():


def dummyLoad():
	w=np.random.randn(3, 3)
	y = np.array([[1,2,3]])
	x = np.array([[1,2,3],[4,5,6],[7,8,9]])
	print predict(0,x[0],w)
	prob=np.zeros([len(x),len(y[0])])
