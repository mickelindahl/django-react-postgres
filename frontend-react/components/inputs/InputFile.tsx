/**
 *Created by Mikael Lindahl on 2019-12-10
 */

import React, {useState, useRef} from 'react';
import styles from "./InputFile.module.scss"

type TProps = {
    onChange: (file:File)=>void,
    disabled?:boolean
}

const InputFile = (props: TProps) => {

    const inputRef = useRef(null)
    const [selectedFile, setSelectedFile] = useState<File>(null);
    const [isSelected, setIsSelected] = useState<boolean>(false);

    const onChangeFile = (event: React.ChangeEvent<HTMLInputElement>) => {

        let file = event.target.files[0]
        props.onChange(file)

        setSelectedFile(event.target.files[0]);
        setIsSelected(true);
    };

    return (
        <div className={styles['input-file']}>
            <input disabled={props.disabled}
                   type="file"
                   name="file"
                   onChange={onChangeFile}
                   ref={inputRef}
            />
            <button className={'btn btn-secondary'} onClick={()=>inputRef.current.click()}>Choose file</button>
            {isSelected ? (
                <div className={'mt-2'}>
                    <small className={'text-muted'}>
                    <p className={'ms-1 mb-1'}>Filename: {selectedFile.name}</p>
                    <p className={'ms-1 mb-1'}>Filetype: {selectedFile.type}</p>
                    <p className={'ms-1 mb-1'} >Size in bytes: {selectedFile.size}</p>
                    <p className={'ms-1 mb-1'}>
                        lastModifiedDate:{' '}
                        {(new Date(selectedFile.lastModified)).toLocaleDateString()}
                    </p>
                    </small>
                </div>
            ) : (
                <div className={'mt-2'}>
                <small className={'text-muted'}><p className={'ms-1 mb-1'}>Select a file to show details</p></small>
                </div>
            )}
        </div>
    )
}

export default InputFile