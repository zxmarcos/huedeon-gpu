
Huedeon GPU design
-----------------------------

Triangle rasterizer with vertex-color and texturing support.

For Terasic DE1-SoC

![gpu](https://user-images.githubusercontent.com/1381933/109404717-78b99800-7947-11eb-95c8-bb9f3679ee2f.gif)
![gpu2](https://user-images.githubusercontent.com/1381933/111018346-0f9a4180-8397-11eb-9be0-59de2aa1a450.gif)

https://user-images.githubusercontent.com/578310/147430514-69140b30-1381-4445-8e61-93a0ea248c9c.mp4


Running with FuseSoC
-----------------------

```bash
sudo pip3 install fusesoc
fusesoc library add local .
fusesoc run --target=[TARGET] zxmarcos:huedeon:huedeon:0.0.1
```

#### Supported Targets

* `qmtech_xc7k325t_ddr3`
* `de1-soc`


#### Generate SVF from Vivado

```bash
vivado -mode batch -source data/qm_xc7k325t_ddr3_svf.cmd
```
