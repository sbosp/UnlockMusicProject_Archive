use pyo3::exceptions::PyValueError;
use pyo3::prelude::*;
use umc_kuwo::{Decipher, Header};

/// Python错误类型包装
#[derive(Debug)]
pub struct PythonError(String);

impl std::convert::From<umc_kuwo::KuwoCryptoError> for PythonError {
    fn from(err: umc_kuwo::KuwoCryptoError) -> Self {
        PythonError(format!("{}", err))
    }
}

impl std::convert::From<PythonError> for PyErr {
    fn from(err: PythonError) -> PyErr {
        PyValueError::new_err(err.0)
    }
}

/// Kuwo头部信息Python包装
#[pyclass(name = "KuwoHeader")]
pub struct PyKuwoHeader {
    inner: Header,
}

#[pymethods]
impl PyKuwoHeader {
    /// 从字节数据解析Kuwo头部
    #[new]
    pub fn new(header_data: &[u8]) -> PyResult<Self> {
        let header = Header::from_bytes(header_data)
            .map_err(PythonError::from)?;
        Ok(PyKuwoHeader { inner: header })
    }

    /// 获取质量ID（用于Android Kuwo APP）
    #[getter]
    pub fn quality_id(&self) -> u32 {
        self.inner.get_quality_id()
    }

    /// 获取资源ID
    #[getter]
    pub fn resource_id(&self) -> u32 {
        self.inner.resource_id
    }

    /// 获取版本号
    #[getter]
    pub fn version(&self) -> u32 {
        self.inner.version
    }
}

/// Kuwo解密器Python包装
#[pyclass(name = "KuwoDecipher")]
pub struct PyKuwoDecipher {
    inner: Decipher,
}

#[pymethods]
impl PyKuwoDecipher {
    /// 创建解密器实例
    #[new]
    #[pyo3(signature = (header, ekey=None))]
    pub fn new(header: &PyKuwoHeader, ekey: Option<String>) -> PyResult<Self> {
        let decipher = Decipher::new(&header.inner, ekey)
            .map_err(PythonError::from)?;
        Ok(PyKuwoDecipher { inner: decipher })
    }

    /// 解密数据块
    pub fn decrypt(&self, data: Vec<u8>, offset: usize) -> PyResult<Vec<u8>> {
        let mut buffer = data;
        self.inner.decrypt(&mut buffer, offset);
        Ok(buffer)
    }

    /// 解密数据块（原地修改）
    pub fn decrypt_inplace(&self, mut data: Vec<u8>, offset: usize) -> PyResult<Vec<u8>> {
        self.inner.decrypt(&mut data, offset);
        Ok(data)
    }
}

/// 创建Kuwo V2解密器
#[pyfunction]
pub fn create_v2_cipher(ekey: &str) -> PyResult<PyKuwoDecipher> {
    let cipher = umc_kuwo::CipherV2::new_from_ekey(ekey)
        .map_err(|err| PythonError(format!("{}", err)))?;
    
    let decipher = Decipher::V2(cipher);
    Ok(PyKuwoDecipher { inner: decipher })
}

/// Python模块定义
#[pymodule]
fn um_python(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_class::<PyKuwoHeader>()?;
    m.add_class::<PyKuwoDecipher>()?;
    m.add_function(wrap_pyfunction!(create_v2_cipher, m)?)?;
    
    m.add("__version__", env!("CARGO_PKG_VERSION"))?;
    
    Ok(())
}