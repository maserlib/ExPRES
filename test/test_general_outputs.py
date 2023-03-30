#−∗− coding : utf−8 −∗−

from spacepy import pycdf

def testing_polarization(file_ref,file_to_test):
	cdf_ref = pycdf.CDF(file_ref) 
	cdf_to_test = pycdf.CDF(file_to_test)
	error_sec = 0 
	error_freq = 0 
	error_polar = 0 


	for i_freq,i_time in zip(range(cdf_ref["Frequency"].shape[0]), range(cdf_ref["Epoch"].shape[0])): 
		if (cdf_to_test["Frequency"][i_freq]-cdf_ref["Frequency"][i_freq]) != 0: 
			error_freq += 1
		if (cdf_to_test["Epoch"][i_time]-cdf_ref["Epoch"][i_time]).total_seconds() != 0:
			error_sec += 1  
		if cdf_to_test["Polarization"][i_time,i_freq] - cdf_ref["Polarization"][i_time,i_freq] != 0: 
			print("polar") 
			error_polar+=1 

	return(error_sec, error_freq, error_polar)

def testing_theta(file_ref,file_to_test):

	cdf_ref = pycdf.CDF(file_ref) 
	cdf_to_test = pycdf.CDF(file_to_test)

	error_sec = 0 
	error_freq = 0 
	error_theta_north = 0 
	error_theta_south = 0 
	for i_freq,i_time in zip(range(cdf_ref["Frequency"].shape[0]), range(cdf_ref["Epoch"].shape[0])): 
		if (cdf_to_test["Frequency"][i_freq]-cdf_ref["Frequency"][i_freq]) != 0: 
			error_freq += 1
		if (cdf_to_test["Epoch"][i_time]-cdf_ref["Epoch"][i_time]).total_seconds() != 0:
			error_sec += 1  

	if cdf_to_test["Theta"][i_time,i_freq,0] - cdf_ref["Theta"][i_time,i_freq,0] != 0: 
		error_theta_north += 1 
	

	if cdf_to_test["Theta"][i_time,i_freq,1] - cdf_ref["Theta"][i_time,i_freq,1] != 0: 
		error_theta_south += 1 

	return(error_sec, error_freq, error_theta_north, error_theta_south)
