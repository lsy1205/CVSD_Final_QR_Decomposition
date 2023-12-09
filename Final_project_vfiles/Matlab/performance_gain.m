clear
close all
clc

% Change the packet number (1-6)
packet_no = 3;

switch packet_no
    case 1
        file_R = importdata('.\Result\out_R_SNR10_P1_result.txt');
        file_y_hat = importdata('.\Result\out_y_hat_SNR10_P1_result.txt');
        llr_gld = importdata('.\llr_gld\packet_1\llr_gld.mat');
    case 2
        file_R = importdata('.\Result\out_R_SNR10_P2_result.txt');
        file_y_hat = importdata('.\Result\out_y_hat_SNR10_P2_result.txt');
        llr_gld = importdata('.\llr_gld\packet_2\llr_gld.mat');
    case 3
        file_R = importdata('.\Result\out_R_SNR10_P3_result.txt');
        file_y_hat = importdata('.\Result\out_y_hat_SNR10_P3_result.txt');
        llr_gld = importdata('.\llr_gld\packet_3\llr_gld.mat');
    case 4
        file_R = importdata('.\Result\out_R_SNR15_P4_result.txt');
        file_y_hat = importdata('.\Result\out_y_hat_SNR15_P4_result.txt');
        llr_gld = importdata('.\llr_gld\packet_4\llr_gld.mat');
    case 5
        file_R = importdata('.\Result\out_R_SNR15_P5_result.txt');
        file_y_hat = importdata('.\Result\out_y_hat_SNR15_P5_result.txt');
        llr_gld = importdata('.\llr_gld\packet_5\llr_gld.mat');
    case 6
        file_R = importdata('.\Result\out_R_SNR15_P6_result.txt');
        file_y_hat = importdata('.\Result\out_y_hat_SNR15_P6_result.txt');
        llr_gld = importdata('.\llr_gld\packet_6\llr_gld.mat');
    otherwise
        file_R = importdata('.\Result\out_R_SNR10_P1_result.txt');
        file_y_hat = importdata('.\Result\out_y_hat_SNR10_P1_result.txt');
        llr_gld = importdata('.\llr_gld\packet_1\llr_gld.mat');
end

no_RE_per_packet = 1000;
error_packet = 0;

llr_dut_buffer = [];

for index_RE = 1:size(file_R,1)

    error_RE = 0;

    % ========== R ========== %
    R_s = string(file_R(index_RE,:));

    dataDec = sscanf(R_s, '%5x');
    index = dataDec >= 2^19;
    dataDec(index) = dataDec(index) - 2^20;

    R44_real = dataDec(1)/2^16;
    R34_imag = dataDec(2)/2^16;
    R34_real = dataDec(3)/2^16;
    R24_imag = dataDec(4)/2^16;
    R24_real = dataDec(5)/2^16;
    R14_imag = dataDec(6)/2^16;
    R14_real = dataDec(7)/2^16;
    R33_real = dataDec(8)/2^16;
    R23_imag = dataDec(9)/2^16;
    R23_real = dataDec(10)/2^16;
    R13_imag = dataDec(11)/2^16;
    R13_real = dataDec(12)/2^16;
    R22_real = dataDec(13)/2^16;
    R12_imag = dataDec(14)/2^16;
    R12_real = dataDec(15)/2^16;
    R11_real = dataDec(16)/2^16;

    R11 = R11_real;
    R12 = R12_real+j*R12_imag;
    R13 = R13_real+j*R13_imag;
    R14 = R14_real+j*R14_imag;
    R22 = R22_real;
    R23 = R23_real+j*R23_imag;
    R24 = R24_real+j*R24_imag;
    R33 = R33_real;
    R34 = R34_real+j*R34_imag;
    R44 = R44_real;

    R = [R11 R12 R13 R14;
           0 R22 R23 R24;
           0   0 R33 R34;
           0   0   0 R44;];
    % ======================= %

    % ========== y_hat ========== %
    y_hat_s = string(file_y_hat(index_RE,:));

    dataDec = sscanf(y_hat_s, '%5x');
    index = dataDec >= 2^19;
    dataDec(index) = dataDec(index) - 2^20;

    y_hat_4_imag = dataDec(1)/2^16;
    y_hat_4_real = dataDec(2)/2^16;
    y_hat_3_imag = dataDec(3)/2^16;
    y_hat_3_real = dataDec(4)/2^16;
    y_hat_2_imag = dataDec(5)/2^16;
    y_hat_2_real = dataDec(6)/2^16;
    y_hat_1_imag = dataDec(7)/2^16;
    y_hat_1_real = dataDec(8)/2^16;
    % =========================== %

    Qy1 = y_hat_1_real+j*y_hat_1_imag;
    Qy2 = y_hat_2_real+j*y_hat_2_imag;
    Qy3 = y_hat_3_real+j*y_hat_3_imag;
    Qy4 = y_hat_4_real+j*y_hat_4_imag;

    Qy = [Qy1;
          Qy2;
          Qy3;
          Qy4;];

    [llr_dut, ~] = nrMLD(Qy, R, 'no_use', 0, 'soft');
    llr_dut_buffer = [llr_dut_buffer; llr_dut'];

    for i = 1:8

        if ( sign(llr_dut(i)) == sign(llr_gld(index_RE,i)) )

            if (abs(llr_dut(i)) >= abs(llr_gld(index_RE,i)))

                error_RE = error_RE;

            else

                error_RE = error_RE + (abs(llr_gld(index_RE,i))-abs(llr_dut(i)))/abs(llr_gld(index_RE,i));

            end

        else

            error_RE = error_RE + abs(llr_dut(i)-llr_gld(index_RE,i))/abs(llr_gld(index_RE,i));

        end

    end

    error_RE = error_RE/8;
    error_packet = error_packet + error_RE;

end

error_packet = error_packet/no_RE_per_packet;
disp(['The soft error rate is ', num2str(error_packet*100),'%'])
