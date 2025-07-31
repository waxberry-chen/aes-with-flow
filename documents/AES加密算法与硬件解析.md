### AES加密算法与硬件解析

**声明：本代码中的向量不加说明都默认为列向量**

该算法为对称加密算法，AES在加密时分为很多轮（128-10、192-12、256-14），只是每轮的密钥在发生改变，例如十轮我们就有11个密钥。也就是说AES加密在同步运行两件事：加密明文和变换密钥。

AES在加密明文分为四部分：字节替代、行移位、列混淆和轮密钥加

<img src="C:\Users\lenovo\AppData\Roaming\Typora\typora-user-images\image-20250611154245615.png" alt="image-20250611154245615" style="zoom:50%;" />

其中九轮循环运算的运算过程都是一样的，只是每一轮的密钥不不一样，最终轮少了列混合的过程。

<img src="assets/image-20250611212737255.png" alt="image-20250611212737255" style="zoom:67%;" />

#### 加密过程

##### **1.初始变换**

先将明文16字节化为`4*4`矩阵，初始密钥也化为`4*4`矩阵，然后将两矩阵按字节作异或操作，在rtl中，si代表第i轮输出的经过运算后的明文，ki代表第i轮中输出的变化后的密钥，kib是第i轮中用到的密钥。初始变化在top中进行，剩下的操作交给子模块进行，子模块分为expand_key和one_round两部分，分别用作密钥生成和循环运算，在代码中分别例化为ri和ai模块。



##### **2.循环运算：字节代换&行移位&列混合&轮密钥加**

数据进入one_round后，进行一轮运算，其中table_lookup模块负责了字节代换&行移位&列混合，轮密钥加在one_round中进行

<img src="C:\Users\lenovo\AppData\Roaming\Typora\typora-user-images\image-20250611160919163.png" alt="image-20250611160919163" style="zoom:50%;" />

table_lookup将处理单独的每一列，而T子模块则单独处理每一列的一个字节，一个字节进入T中，先是经过字节代换，由S模块进行S-BOX查找表代换，再由xS模块利用查找表代替列混合操作，这里比较容易晕，因此做一个详细的解释：

列混合的算法如下图所示：

<img src="assets/image-20250611165226431.png" alt="image-20250611165226431" style="zoom:50%;" />

以第一列为例，`s_out[0] = ({02} * s_in[0]) ^ ({03} * s_in[1]) ^ ({01} * s_in[2]) ^ ({01} * s_in[3])`，其中`{03}`可以拆分为`{02} ^ {01}`。

T接收一个字节，并在该模块中将S_in的所有结果都计算出来,输出结果的顺序是

{01} {01} {03} {02} 

```verilog
module T (clk, in, out);
    input         clk;
    input  [7:0]  in;
    output [31:0] out;

    S
    s0 (clk, in, out[31:24]); //X-BOX替换，即s_in * {01} 的结果
    assign out[23:16] = out[31:24]; //对应着两个 s_in * {01}
    xS
    s4 (clk, in, out[7:0]); //通过查找表计算 S_in * {02}
    assign out[15:8] = out[23:16] ^ out[7:0]; //通过异或计算S_in * {03}
endmodule
```

因此得到了一个字节所有列混合的结果，共有4个T模块，代表着一列中所有的列混合结果。因此T模块实现了字节代换和列混合

```verilog
module table_lookup (clk, state, p0, p1, p2, p3);
    input clk;
    input [31:0] state;
    output [31:0] p0, p1, p2, p3;
    wire [7:0] b0, b1, b2, b3;
    
    assign {b0, b1, b2, b3} = state;
    T
    	t0 (clk, b0, {p0[23:0], p0[31:24]}), 
        t1 (clk, b1, {p1[15:0], p1[31:16]}),
        t2 (clk, b2, {p2[7:0],  p2[31:8]} ),
        t3 (clk, b3, p3);
endmodule
```

如图可视，AddRoundKey要进行的操作是：

![image-20250611190838711](assets/image-20250611190838711.png)

其中S'矩阵为经过字节代换&行移位&列混合之后的结果，将结果往前推：

SubBytes

![image-20250611191021089](assets/image-20250611191021089.png)

ShiftRows

![image-20250611191036709](assets/image-20250611191036709.png)

Mixcolums 

<img src="assets/image-20250611165226431.png" alt="image-20250611165226431" style="zoom:50%;" />

其中伽罗华域乘（{02}和{03}部分）的部分用查找表代替了

将所有式子展开可得到以下等式![image-20250611191611843](assets/image-20250611191611843.png)

整理一下用列的顺序表示

```python
#第一列
s'₀,₀ = 2P(a₀,₀) ⊕ 3P(a₁,₁) ⊕ P(a₂,₂) ⊕ P(a₃,₃)
s'₁,₀ = P(a₀,₀) ⊕ 2P(a₁,₁) ⊕ 3P(a₂,₂) ⊕ P(a₃,₃)
s'₂,₀ = P(a₀,₀) ⊕ P(a₁,₁) ⊕ 2P(a₂,₂) ⊕ 3P(a₃,₃)
s'₃,₀ = 3P(a₀,₀) ⊕ P(a₁,₁) ⊕ P(a₂,₂) ⊕ 2P(a₃,₃)
#第二列
s'₀,₁ = 2P(a₀,₁) ⊕ 3P(a₁,₂) ⊕ P(a₂,₃) ⊕ P(a₃,₀)
s'₁,₁ = P(a₀,₁) ⊕ 2P(a₁,₂) ⊕ 3P(a₂,₃) ⊕ P(a₃,₀)
s'₂,₁ = P(a₀,₁) ⊕ P(a₁,₂) ⊕ 2P(a₂,₃) ⊕ 3P(a₃,₀)
s'₃,₁ = 3P(a₀,₁) ⊕ P(a₁,₂) ⊕ P(a₂,₃) ⊕ 2P(a₃,₀)
#第三列
s'₀,₂ = 2P(a₀,₂) ⊕ 3P(a₁,₃) ⊕ P(a₂,₀) ⊕ P(a₃,₁)
s'₁,₂ = P(a₀,₂) ⊕ 2P(a₁,₃) ⊕ 3P(a₂,₀) ⊕ P(a₃,₁)
s'₂,₂ = P(a₀,₂) ⊕ P(a₁,₃) ⊕ 2P(a₂,₀) ⊕ 3P(a₃,₁)
s'₃,₂ = 3P(a₀,₂) ⊕ P(a₁,₃) ⊕ P(a₂,₀) ⊕ 2P(a₃,₁)
#第四列
s'₀,₃ = 2P(a₀,₃) ⊕ 3P(a₁,₀) ⊕ P(a₂,₁) ⊕ P(a₃,₂)
s'₁,₃ = P(a₀,₃) ⊕ 2P(a₁,₀) ⊕ 3P(a₂,₁) ⊕ P(a₃,₂)
s'₂,₃ = P(a₀,₃) ⊕ P(a₁,₀) ⊕ 2P(a₂,₁) ⊕ 3P(a₃,₂)
s'₃,₃ = 3P(a₀,₃) ⊕ P(a₁,₀) ⊕ P(a₂,₁) ⊕ 2P(a₃,₂)
```

又由上面知道T输出的顺序是{01} {01} {03} {02} ，相当于若传入一个`a₀,₀`，则输出为

[P(a₀,₀)，P(a₀,₀)，3P(a₀,₀)，2P(a₀,₀)]，再经过table_lookup模块调序，则lookup_table输出的结果为

```python
#p00 p10 p20 p30
t0 = [2P(a₀,₀),1P(a₀,₀),1P(a₀,₀),3P(a₀,₀)]
t1 = [3P(a₁,₀),2P(a₁,₀),1P(a₁,₀),1P(a₁,₀)]----->p00,p01,p02,p03
t2 = [1P(a₂,₀),3P(a₂,₀),2P(a₂,₀),1P(a₂,₀)]----->
t3 = [1P(a₃,₀),1P(a₃,₀),3P(a₃,₀),2P(a₃,₀)]

#p01 p11 p21 p31
t0 = [2P(a₀,₁),1P(a₀,₁),1P(a₀,₁),3P(a₀,₁)]
t1 = [3P(a₁,₁),2P(a₁,₁),1P(a₁,₁),1P(a₁,₁)]----->p01,p11,p21,p31
t2 = [1P(a₂,₁),3P(a₂,₁),2P(a₂,₁),1P(a₂,₁)]----->
t3 = [1P(a₃,₁),1P(a₃,₁),3P(a₃,₁),2P(a₃,₁)]
#
...
#
...
```

可以看出这里的p并没有按先行后列的顺序，而是按照先列后行的顺序，很逆天，可以将其改为正确的顺序，这样比较直观一点



##### 3.密钥扩展

密钥扩展拥有一套独特的算法，该算法的实现都是居于expand_key_128模块，这里的函数T由三部分组成：字循环、字节代换和轮常量异或

![image-20250611212413048](assets/image-20250611212413048.png)

字循环指的是将目标列上移一个位置

![image-20250611214424331](assets/image-20250611214424331.png)

字节代换就是S-BOX代换，最后一步轮常量异或就是将前两步得到的结果和轮常量进行异或，轮常量为HEX的1，2，4，8，10，20，40，80，，1b和36

<img src="assets/image-20250611223858652.png" alt="image-20250611223858652" style="zoom:67%;" />

电路实现方面，S4只进行S-BOX代换，且将轮异或操作提前尽心，字循环通过S4的连线实现，最后k0a到k3a为缺少字节代换和字循环异或的结果，于是构建了一个流水线用于完成最后一步的操作，最后将输出分为当前用的key和下一轮扩展的key

```verilog
module expand_key_128(clk, in, out_1, out_2, rcon);
    input              clk;
    input      [127:0] in;
    input      [7:0]   rcon;
    output reg [127:0] out_1;
    output     [127:0] out_2;
    wire       [31:0]  k0, k1, k2, k3,
                       v0, v1, v2, v3;
    reg        [31:0]  k0a, k1a, k2a, k3a;
    wire       [31:0]  k0b, k1b, k2b, k3b, k4a;

    assign {k0, k1, k2, k3} = in;
    
    assign v0 = {k0[31:24] ^ rcon, k0[23:0]};
    assign v1 = v0 ^ k1;
    assign v2 = v1 ^ k2;
    assign v3 = v2 ^ k3;

    always @ (posedge clk)
        {k0a, k1a, k2a, k3a} <= {v0, v1, v2, v3};

    S4
        S4_0 (clk, {k3[23:0], k3[31:24]}, k4a);

    assign k0b = k0a ^ k4a;
    assign k1b = k1a ^ k4a;
    assign k2b = k2a ^ k4a;
    assign k3b = k3a ^ k4a;

    always @ (posedge clk)
        out_1 <= {k0b, k1b, k2b, k3b};

    assign out_2 = {k0b, k1b, k2b, k3b};
endmodule
```



##### 4.最后一轮变换

最后一轮相比之前少了一个列混合，因此直接例化S进行替换即可，不用例化table_lookup，这里的硬件也是行列搞反了，将其修改以符合直觉

```verilog
module final_round (clk, state_in, key_in, state_out);
    input              clk;
    input      [127:0] state_in;
    input      [127:0] key_in;
    output reg [127:0] state_out;
    wire [31:0] s0,  s1,  s2,  s3,
                z0,  z1,  z2,  z3,
                k0,  k1,  k2,  k3;
    wire [7:0]  p00, p01, p02, p03,
                p10, p11, p12, p13,
                p20, p21, p22, p23,
                p30, p31, p32, p33;
    
    assign {k0, k1, k2, k3} = key_in;
    
    assign {s0, s1, s2, s3} = state_in;

    S4
        S4_1 (clk, s0, {p00, p01, p02, p03}),
        S4_2 (clk, s1, {p10, p11, p12, p13}),
        S4_3 (clk, s2, {p20, p21, p22, p23}),
        S4_4 (clk, s3, {p30, p31, p32, p33});

    assign z0 = {p00, p11, p22, p33} ^ k0;
    assign z1 = {p10, p21, p32, p03} ^ k1;
    assign z2 = {p20, p31, p02, p13} ^ k2;
    assign z3 = {p30, p01, p12, p23} ^ k3;

    always @ (posedge clk)
        state_out <= {z0, z1, z2, z3};
endmodule
```

