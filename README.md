PhageData
=========

<!--- [![pipeline status](https://gitlab.com/PhageDisplayInference/PhageData.jl/badges/master/pipeline.svg)](https://gitlab.com/PhageDisplayInference/PhageData.jl/commits/master) --->

A [Julia](https://julialang.org) package for download and process sequencing data from phage display experiments. Data are freely accessible from the related publications (see below). 

## Installing

Install https://github.com/infernet-h2020/PhageBase.jl before using this. To install this package from Julia REPL type `]` to enter into the Package Manager prompt and then type `add https://github.com/infernet-h2020/PhageBase.jl`.

## Usage

Automatically acquire and process data sets to test phage display inference algorithms.


`boyer2016pnas_pvp()` and `boyer2016pnas_dna()` acquire the datasets from the paper http://www.pnas.org/content/113/13/3482.

`fowler2010nmeth()` acquires the dataset from the paper	https://www.nature.com/articles/nmeth.1492.

`olson2014currbio_gb1()` acquires the dataset from the paper http://www.sciencedirect.com/science/article/pii/S0960982214012688.

`aray2012pnas()` acquires the dataset from the paper http://www.pnas.org/content/109/42/16858 (this function currently is not working).

`rubin2017genbio_c1()` acquires the dataset from https://doi.org/10.1186/s13059-017-1272-5.
<a name="infernet_logo"/>
<div align="center">
<a href="http://www.infernet.eu/" target="_blank">
<img src="http://www.infernet.eu/wp-content/uploads/2017/03/INFERNET_Wordmark_HR.png" alt="infernet logo" width="200" height="50"></img>
</a>
</div>


This work is supported by [INFERNET](http://www.infernet.eu) : "New algorithms for inference and optimization from large-scale biological data".

<a name="eu_banner"/>
<div align="center">
<a href="https://europa.eu/european-union/index_en" target="_blank">
<img src="http://www.infernet.eu/wp-content/uploads/2017/03/flag_yellow_high.jpg" alt="eu banner" width="40" height="30"></img>
</a>
</div>

<p align="center"><sup>
The INFERNET project is co-funded by the European Union’s H2020 research and innovation programme under the Marie Sklodowska-Curie grant agreement number 734439.
</sup>
</p>

