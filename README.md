# Make a Pipeline CPU
Support insrtuction LD, SD, BEQ, BNE, ADDI, XORI, ORI, ANDI, SLLI, SRLI, ADD, SUB, XOR, OR, AND, STOP.

## Drafts
1.  Instruction memory
   
![圖片](https://github.com/TsungHsuan-Pan/riscv-cpu/assets/144418039/f9b23d9b-5c4f-42b1-94fa-8cc5fa9939dc)

2. Data memory

![圖片](https://github.com/TsungHsuan-Pan/riscv-cpu/assets/144418039/c0f8719c-f02f-4259-b9a0-9d6c3bfbebdf)

3. Diagram of CPU

![圖片](https://github.com/TsungHsuan-Pan/riscv-cpu/assets/144418039/81ff50d0-815b-4234-914c-d232f4dae62a)

## Yosys - Analyze Tool
1. Check the timing of the critical path of CPU design.
2. Can use iamge provide by NTU to build Yosys
```bash
docker pull ntuca2020/hw4 # size ~ 1.28G
docker run --name=test -it ntuca2020/hw4
cd /root
ls
```

## Make file
```bash
make // Compile
make test // Test all test cases
make time // Show the timing and area used of cpu
```
