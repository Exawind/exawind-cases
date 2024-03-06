import matplotlib, glob
matplotlib.use('Agg')
import pyFAST.input_output as io
from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.pyplot as plt
import numpy as np
import multiprocessing
from multiprocessing import Pool

def load_case(of_output_file):
    return io.fast_output_file.FASTOutputFile(of_output_file).toDataFrame()


def plot_time_series(case_data, case_data2, labels):

    tmp = case_data[0].columns.tolist()
    plot_columns = tmp[1:48] + tmp[-13:]

    cidx = np.array(range(6)).reshape((2,3))

    with PdfPages('iea15mw_powercurve.pdf') as pfpgs:
        for c in plot_columns:
            fig, ax = plt.subplots(2, 3, figsize=(6.4,4.8) )
            for i in range(2):
                for j in range(3):
                    ax[i,j].plot( case_data[cidx[i,j]][c].iloc[-50:],'+-' )
                    #ax[i,j].plot( case_data2[cidx[i,j]][c].iloc[:14400] )
                    ax[i,j].set_title(labels[cidx[i,j]])
            plt.title(c)
            plt.tight_layout()
            pfpgs.savefig()
            plt.close(fig)


if __name__=="__main__":


    windspeeds = np.array([5.0, 6.0, 7.0, 8.0, 9.0,
                           10.0, 12.0, 14.0,
                           17.0, 20.0, 23.0, 25.0])
    windspeeds = np.array([12.0, 14.0, 17.0, 20.0, 23.0, 25.0])

    fcases = [ 'fortran_wind_speed_{:04.2f}/openfast_run/IEA-15-240-RWT-Monopile.out'.format(wspd) for wspd in windspeeds ]
    cases = [ 'wind_speed_{:04.2f}/combined_run/IEA-15-240-RWT-Monopile.out'.format(wspd) for wspd in windspeeds ]

    labels = [ 'ws = {:04.2f} m/s'.format(wspd) for wspd in windspeeds ]

    with Pool(13) as p:
        case_data = p.map(load_case, cases)
        #fcase_data = p.map(load_case, fcases)

    plot_time_series(case_data, None, labels)
