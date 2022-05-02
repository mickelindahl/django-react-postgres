/**
 *Created by Mikael Lindahl on 2022-05-02
 */

import React, {useState} from 'react';
import InputFile from "../inputs/InputFile";
const debug = require('debug')('bk-manager:frontend-react:components:items:UserDataItemEdit');
import {useAppDispatch} from "../../redux/hooks";
import useFormUpload from "../../hooks/useFormUpload";
import {updateUserData} from "../../redux/slices/userDataSlice";
import url from "../../constants/url"

type Tprops = {
    id:number,
    onClose:()=>void
}

const UserDataItemEdit = (props:Tprops) => {

    const [success, setSuccess] = useState(false)
    const [error, setError] = useState(null)
    const dispatch = useAppDispatch()

    const {
        formData,
        onFormUpload,
        setFormData
    } = useFormUpload({
        path:  url.FILE_UPLOAD,
        onError: error => setError(error),
        onSuccess: result => {
            dispatch(updateUserData(result.user_data))
            setSuccess(true)
        },
    })

    return  <div>
        <div className={'m-1'}>
            <InputFile onChange={file => {

                debug('file', file)
                const formData = new FormData();
                formData.append('File', file);
                debug('formData', formData)
                setFormData(formData)
            }}/>
        </div>
        <div className={'m-1'}>
            <button disabled={formData == null}
                    className={'btn btn-primary me-1'}
                    onClick={() => onFormUpload(props.id)}>
                Save
            </button>
            <button className={'btn btn-danger'}
                    onClick={() => {
                        setFormData(null)
                        props.onClose()
                    }}>Close
            </button>
        </div>
        {success && <p className={'text-success'}>File uploaded!</p>}
        {error && <p className={'text-danger'}>File uploaded failed!</p>}
    </div>

}

export default UserDataItemEdit