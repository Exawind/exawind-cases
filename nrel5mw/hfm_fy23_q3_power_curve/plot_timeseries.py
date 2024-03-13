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


def plot_time_series(case_data, case_data2, case_data3, labels):

    tmp = case_data[0].columns.tolist()
    print(tmp)
    plot_columns = tmp[1:]
    plot_columns = ['BldPitch1_[deg]', 'RotSpeed_[rpm]', 'GenSpeed_[rpm]', 'RotTorq_[kN-m]', 'TwrBsFxt_[kN]', 'TwrBsFyt_[kN]', 'TwrBsFzt_[kN]', 'TwrBsMxt_[kN-m]', 'TwrBsMyt_[kN-m]', 'TwrBsMzt_[kN-m]', 'B1RootFxr_[N]', 'B1RootFyr_[N]', 'B1RootFzr_[N]', 'B1RootMxr_[N-m]', 'B1RootMyr_[N-m]', 'B1RootMzr_[N-m]', 'B1TipTDxr_[m]', 'B1TipTDyr_[m]', 'B1TipTDzr_[m]', 'B1TipRDxr_[-]', 'B1TipRDyr_[-]', 'B1TipRDzr_[-]', 'GenPwr_[kW]', 'GenTq_[kN-m]']

    cidx = np.array(range(12)).reshape((3,4))
    print(cidx.shape)

    windspeeds = np.array([5.0, 7.0, 8.0, 9.0,
                           10.0, 12.0, 14.0,
                           17.0, 20.0, 23.0, 25.0])

    with PdfPages('nrel5mw_avg_powercurve.pdf') as pfpgs:
        for p in plot_columns:
            avg_p = [c[p].iloc[-1440:].mean() for c in case_data ]
            avg_pf = [c[p].iloc[-1440:].mean() for c in case_data2 ]
            avg_pf_turb = [c[p].iloc[-1440:].mean() for c in case_data3 ]
            fig = plt.figure()
            plt.plot(windspeeds, avg_p, '+-', label='FSI')
            plt.plot(windspeeds, avg_pf, '*-', label='BEM')
            plt.plot(windspeeds, avg_pf_turb, '*-', label='BEM - Nalu-wind polars')
            if ('GenPwr' in p):
                plt.plot([8.0], [1429.6493189571993], 'd', label='Nalu-wind rigid')
            plt.xlabel('Wind speed (m/s)')
            plt.ylabel(p)
            plt.legend(loc=0)
            plt.grid()
            plt.tight_layout()
            pfpgs.savefig()
            plt.close(fig)

    with PdfPages('nrel5mw_powercurve.pdf') as pfpgs:
        for c in plot_columns:
            fig, ax = plt.subplots(3, 4, figsize=(6.4,4.8) )
            print(c, ax.shape)
            for i in range(3):
                for j in range(4):
                    try:
                        ax[i,j].plot( case_data[cidx[i,j]][c].iloc[3000::10])
                        ax[i,j].set_title(labels[cidx[i,j]])
                    except:
                        pass
            plt.title(c)
            plt.tight_layout()
            pfpgs.savefig()
            plt.close(fig)

    with PdfPages('nrel5mw_powercurve_turb.pdf') as pfpgs:
        for c in plot_columns:
            fig, ax = plt.subplots(3, 4, figsize=(6.4,4.8) )
            print(c, ax.shape)
            for i in range(3):
                for j in range(4):
                    try:
                        ax[i,j].plot( case_data2[cidx[i,j]][c].iloc[3000::10])
                        ax[i,j].plot( case_data3[cidx[i,j]][c].iloc[3000::10])
                        ax[i,j].set_title(labels[cidx[i,j]])
                    except:
                        pass
            plt.title(c)
            plt.tight_layout()
            pfpgs.savefig()
            plt.close(fig)


if __name__=="__main__":


    windspeeds = np.array([5.0, 7.0, 8.0, 9.0,
                           10.0, 12.0, 14.0,
                           17.0, 20.0, 23.0, 25.0])
    #windspeeds = np.array([12.0, 14.0, 17.0, 20.0, 23.0, 25.0])

    fcases = [ 'wind_speed_{:04.2f}/openfast_run/5MW_Land_BD_DLL_WTurb.out'.format(wspd) for wspd in windspeeds ]
    fcases_turb = [ 'wind_speed_{:04.2f}/openfast_run2/5MW_Land_BD_DLL_WTurb.out'.format(wspd) for wspd in windspeeds ]
    cases = [ 'wind_speed_{:04.2f}/combined/5MW_Land_BD_DLL_WTurb.out'.format(wspd) for wspd in windspeeds ]


    labels = [ 'ws = {:04.2f} m/s'.format(wspd) for wspd in windspeeds ]

    with Pool(13) as p:
        case_data = p.map(load_case, cases)
        fcase_data = p.map(load_case, fcases)
        fcase_data_turb = p.map(load_case, fcases_turb)

    plot_time_series(case_data, fcase_data, fcase_data_turb, labels)
