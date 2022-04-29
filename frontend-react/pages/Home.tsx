import React, {useState} from "react";
import InputFile from "../components/inputs/InputFile";
import useFormUpload from "../hooks/useFormUpload";
import UserDataItem from "../components/items/UserDataItem";
import {useAppSelector, useAppDispatch} from '../redux/hooks'
import {updateUserData} from '../redux/slices/userDataSlice'

const debug = require('debug')('bk-manager:frontend-react:routers:RoutingApp');

const Home = () => {

    const [url, setUrl] = useState(null)
    const [success, setSuccess] = useState(false)
    const [error, setError] = useState(null)
    const dispatch= useAppDispatch()
    const userData = useAppSelector((state) => state.userData.value)

    const {
        formData,
        onFormUpload,
        setFormData
    } = useFormUpload({
        path: '/api/file-upload',
        onError: error => setError(error),
        onSuccess: result => {
            dispatch(updateUserData(result.user_data))
            setSuccess(true)
        },
    })

    console.log(userData)

    return (
        <div className={'container'}>
            <h1 className={'text-center pb-3'}>User data</h1>
            <div className="row">
                <div className="col-sm">
                    <h3 className={'text-center pb-3'}>Add</h3>
                    <InputFile onChange={file => {
                        const formData = new FormData();
                        formData.append('File', file);
                        setFormData(formData)
                    }}/>
                    <button disabled={formData == null} className={'btn btn-primary'} onClick={onFormUpload}>Upload
                    </button>
                    {success && <p className={'text-success'}>File uploaded!</p>}
                    {error && <p className={'text-danger'}>File uploaded failed!</p>}
                </div>
                <div className="col-sm">
                    <h3 className={'text-center pb-3'}>Files</h3>
                    {userData.map((d, i)=><UserDataItem key={i} name={d.name} url={d.url} onClick={setUrl}/>)}
                </div>
                <div className="col-sm">
                    <h3 className={'text-center pb-3'}>Preview</h3>
                    {url!=null && <iframe src={url} title="W3Schools Free Online Web Tutorials"></iframe>}
                </div>
            </div>
        </div>
    )
}

export default Home