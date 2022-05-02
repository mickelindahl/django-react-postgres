import React, {useState, useRef} from "react";
import InputFile from "../components/inputs/InputFile";
import useFormUpload from "../hooks/useFormUpload";
import UserDataItem from "../components/items/UserDataItem";
import {useAppSelector, useAppDispatch} from '../redux/hooks'
import {updateUserData} from '../redux/slices/userDataSlice'
import UserDataItemEdit from "../components/items/UserDataItemEdit";
import UploadFile from "../components/inputs/UploadFile";
const debug = require('debug')('bk-manager:frontend-react:pages:Home');

const Home = () => {

    const inputFileRef = useRef(null)
    const [url, setUrl] = useState(null)
    const [success, setSuccess] = useState(false)
    const [error, setError] = useState(null)
    const [editItemId, setEditItemId] = useState(-1)
    const dispatch = useAppDispatch()
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
        <div className={' d-flex justify-content-center align-items-center h-100'}>
            <div className={'container'}>
                <h1 className={'text-center pb-3'}>User data</h1>
                <div className="row">
                    <div className="col-xl">
                        <h3 className={'text-center pb-3'}>Add</h3>
                        <UploadFile/>
                    </div>
                    <div className="col-xl">
                        <h3 className={'text-center pb-3'}>Files</h3>
                        {userData.map(item =>
                                <UserDataItem
                                    key={item.id}
                                    item={item}
                                    onClick={setUrl}
                                />
                        )}
                    </div>
                    <div className="col-xl">
                        <h3 className={'text-center pb-3'}>Preview</h3>
                        {url != null && <iframe src={url} title="W3Schools Free Online Web Tutorials"></iframe>}
                    </div>
                </div>
            </div>
        </div>
    )
}

export default Home