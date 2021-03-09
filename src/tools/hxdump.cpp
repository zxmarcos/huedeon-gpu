// hxdump.cpp : Este arquivo contém a função 'main'. A execução do programa começa e termina ali.

#include <iostream>
#include <cstdio>
#include <cstdint>

template <typename T>
void dump_mem(FILE* fp, FILE* wf)
{
    fseek(fp, 0, SEEK_END);
    size_t size = ftell(fp);
    fseek(fp, 0, SEEK_SET);

    size_t pad = size % sizeof(T);
    size += pad;

    size_t words = size / sizeof(T);
    T* buffer = new T[words];
    memset(buffer, 0, size);
    fread(buffer, 1, size, fp);

    std::cout << "Dumping " << words << " words..." << std::endl;
    char fmt[8];
    snprintf(fmt, 8, "%%0%dX\n", sizeof(T) * 2);
    for (size_t i = 0; i < words; i++) {
        fprintf(wf, fmt, buffer[i]);
    }

    delete[] buffer;
}

template <typename T>
void dump_mif(FILE* fp, FILE* wf)
{
    fseek(fp, 0, SEEK_END);
    size_t size = ftell(fp);
    fseek(fp, 0, SEEK_SET);

    size_t pad = size % sizeof(T);
    size += pad;

    size_t words = size / sizeof(T);
    T* buffer = new T[words];
    memset(buffer, 0, size);
    fread(buffer, 1, size, fp);

    std::cout << "Dumping " << words << " words..." << std::endl;

    fprintf(wf, "WIDTH=%d;\n", sizeof(T) * 8);
    fprintf(wf, "DEPTH=%d;\n\n", words);

    fprintf(wf, "ADDRESS_RADIX = HEX;\n");
    fprintf(wf, "DATA_RADIX = HEX;\n\n");

    fprintf(wf, "CONTENT BEGIN\n");
    char range_fmt[64];
    snprintf(range_fmt, 64, "\t[%%X..%%X]  :  %%0%dX;\n", sizeof(T) * 2);

    T last_value;
    bool last_value_is_valid = false;
    size_t last_count = 0;
    size_t last_start_offset = 0;

    char single_fmt[64];
    snprintf(single_fmt, 64, "\t%%X  :  %%0%dX;\n", sizeof(T) * 2);
    for (size_t i = 0; i < words; i++) {
#if 0
        const T& v = buffer[i];
        if (last_value_is_valid) {
            bool flush = (i == words - 1);
            if (last_value == v) {
                last_count++;
                if (!flush)
                    continue;
            }

            if (last_count == 1) {
                fprintf(wf, single_fmt, i, last_value);
            } else {
                fprintf(wf, range_fmt, last_start_offset, i-1, last_value);
            }
            last_value = v;
            last_start_offset = i;
            last_count = 1;
        }
        else {
            last_value = v;
            last_value_is_valid = true;
            last_start_offset = i;
            last_count = 1;
        }
#else
        fprintf(wf, single_fmt, i, buffer[i]);
#endif
    }
    fprintf(wf, "END;\n");
    delete[] buffer;
}

int main(int argc, char *argv[])
{
    if (argc < 4) {
        std::cout << "hxdump <input> <output> <4/2/1>" << std::endl;
        return 1;
    }

    FILE* fp = nullptr;
    errno_t err;
    err = fopen_s(&fp, argv[1], "rb");
    if (err != 0) {
        std::cout << argv[1] << " não foi possível abrir" << std::endl;
        return 1;
    }
    fseek(fp, 0, SEEK_END);
    size_t size = ftell(fp);
    fseek(fp, 0, SEEK_SET);

    if (size == 0) {
        std::cout << "Arquivo vazio" << std::endl;
        return 1;
    }

    FILE* wf = nullptr;
    err = fopen_s(&wf, argv[2], "w");
    if (err != 0) {
        std::cout << argv[2] << " não foi possível abrir" << std::endl;
        return 1;
    }

#if 0
    size_t pad = size % 4;
    size += pad;

    size_t dwords = size / 4;
    int32_t* buffer = new int32_t[dwords];
    memset(buffer, 0, size);
    fread(buffer, 1, size, fp);

    std::cout << "Dumping " << dwords << " dwords..." << std::endl;
    for (size_t i = 0; i < dwords; i++) {
        fprintf(wf, "%08X\n", buffer[i]);
    }
    

    delete[] buffer;
#else
    if (!strcmp(argv[3], "mem4"))
        dump_mem<uint32_t>(fp, wf);
    else if (!strcmp(argv[3], "mem2"))
        dump_mem<uint16_t>(fp, wf);
    else if (!strcmp(argv[3], "mem1"))
        dump_mem<uint8_t>(fp, wf);
    if (!strcmp(argv[3], "mif4"))
        dump_mif<uint32_t>(fp, wf);
    else if (!strcmp(argv[3], "mif2"))
        dump_mif<uint16_t>(fp, wf);
    else if (!strcmp(argv[3], "mif1"))
        dump_mif<uint8_t>(fp, wf);
#endif
    fclose(wf);
    fclose(fp);

    return 0;
}

