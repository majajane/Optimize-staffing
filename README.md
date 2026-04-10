# optimize-staffing
Math Modeling (Final Course Output)

## Overview
The goal of this study is to analyze the occupancy data in the e-Library and to determine the busiest period. This way, the library does not exceed its capacity and allows students to utilize available space effectively.

## Mathematical Models
- **Time Series**: Tracks hourly occupancy changes
- **Moving Average**: Smooths technique to lessen fluctuations (k = 3)
- **Rate of Change**: Identifies when occupancy rises or falls
- **Linear Programming**: Optimizes staff allocation at the e-Lib
  
## How to access the code
- Download MATLAB R2025b and Optimization Toolbox (for `linprog`)
- Launch MATLAB
- Go to the files of this repository and click view file
- Download the raw files (`SEPT.csv`,`NOV.csv`, and `optimize-staffing.m`)
- Go to the downloaded files and open the MATLAB file
- Update the path folder in line 5 to where the CSV files are located
- Press F5 or go to editor and run `optimize-staffing.m`
- Figures will automatically show up
- Results will appear in the command window

## Results Summary
	- Current peak staff: 18
	- Optimal peak staff: 11
	- Total working hours saved: 50/day (30.9% reduction)
	
## Outputs

- **Figures** — Will automatically show up (time series, moving average, rate of change)
- **Command Window Results** — After running the script, the MATLAB command window will display:
  - Optimal staff allocation per time block
  - Total staff required
  - Busiest periods identified from the e-Library occupancy data

## Files
	- `optimize-staffing.m` - main MATLAB script
	- `SEPT.csv` - September occupancy data
	- `NOV.csv` - November occupancy data
