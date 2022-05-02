/**
 *Created by Mikael Lindahl on 2022-04-28
 */

"use strict";

/**
 *Created by Mikael Lindahl on 2022-04-28
 */

import React, {useState} from 'react';
import {UserData} from "../redux/slices/userDataSlice";


type TProps = {
    headers?: {}
    onError: (error: any) => void
    onSuccess: (result: {
        message: string,
        user_data: UserData
    }) => void
    path: string
}

const useFormUpload = (props: TProps) => {

    const [formData, setFormData] = useState<FormData>(null)
    const headers = props.headers || {}

    const onFormUpload = (id?: number) => {

        console.log(formData, id)

        const url = id ? `${props.path}/${id}` : props.path

        console.log(formData, id, url)

        fetch(
            url,
            {
                method: 'POST',
                headers,
                body: formData,
            }
        )
            .then((response) => response.json())
            .then((result) => {

                if (result.error) {
                    throw result.error
                    // props.onError(result.error)
                    // console.error('Error:', result.error);
                    // return
                }

                props.onSuccess(result)
                console.log('Success:', result);
            })
            .catch((error) => {
                props.onError(error)
                console.error('Error:', error);
            });
    };


    return {formData, onFormUpload, setFormData}
}

export default useFormUpload