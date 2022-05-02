/**
 *Created by Mikael Lindahl on 2022-05-02
 */

import React, {useState} from 'react';
import InputFile from "./InputFile";
import useFormUpload from "../../hooks/useFormUpload";
import {updateUserData} from "../../redux/slices/userDataSlice";
import {useAppDispatch} from "../../redux/hooks";

const debug = require('debug')('bk-manager:frontend-react:components:inputs:UploadFile');

const UploadFile = () => {

    const [success, setSuccess] = useState(false)
    const [error, setError] = useState(null)
    const dispatch = useAppDispatch()

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

    return <div>
        <InputFile onChange={file => {
            const formData = new FormData();
            formData.append('File', file);
            debug('formData', formData)
            setFormData(formData)
        }}/>
        <button disabled={formData == null} className={'mt-1 btn btn-primary'}
                onClick={() => onFormUpload()}>Upload
        </button>
        {success && <p className={'text-success'}>File uploaded!</p>}
        {error && <p className={'text-danger'}>File uploaded failed!</p>}
    </div>

}

export default UploadFile