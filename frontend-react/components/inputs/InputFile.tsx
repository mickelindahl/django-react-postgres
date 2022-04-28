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
                <div>
                    <p>Filename: {selectedFile.name}</p>
                    <p>Filetype: {selectedFile.type}</p>
                    <p>Size in bytes: {selectedFile.size}</p>
                    <p>
                        lastModifiedDate:{' '}
                        {(new Date(selectedFile.lastModified)).toLocaleDateString()}
                    </p>
                </div>
            ) : (
                <p>Select a file to show details</p>
            )}
        </div>
    )
}

export default InputFile