import React, {useState} from "react";
import InputFile from "../components/inputs/InputFile";
import useFormUpload from "../hooks/useFormUpload";
const debug = require('debug')('bk-manager:frontend-react:routers:RoutingApp');

const Home = ()=> {

    const [success, setSuccess] = useState(false)

    const  {
        onFormUpload,
        setFormData
    } = useFormUpload({path:'/api/file-upload', onSuccess:()=>setSuccess(true)})

    return (
        <div className={'container'}>
            <h1>Home</h1>
            <InputFile onChange={file=>{
                const formData = new FormData();
                formData.append('File', file);
                setFormData(formData)
            }}/>
            <button className={'btn btn-primary'} onClick={onFormUpload}></button>
            {success && <p className={'text-success'}>File uploaded!</p>}
        </div>
    )
}

export default Home