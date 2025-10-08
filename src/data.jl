


function generate_process_string(m::KeplerGLMap, d::FieldsRowsData)
    # frd = JSON3.read(d.json);
    # @show d.json

    # datasets: [JSON.parse(`$(d.json)`)],
    return """
        keplergljson = {
            datasets: [$(d.json)],
            config: $(JSON3.write(m.config))
        };

        processeddata = [keplerGl.processKeplerglJSON(keplergljson).datasets[0].data]

        // for debugging
        // console.log(processeddata)

        // match id with old datasets
        newDataset = processeddata.map((d, i) => ({
        version: '$(m.config[:version])',
        data: {
            id: '$(d.id)',
            label: '$(d.id)',
            allData: d.rows,
            fields: d.fields
        }
        }));

        newDatasets.push(newDataset[0]);
        
        // for debugging
        // console.log(newDataset)
    """
end

function generate_process_string(m::KeplerGLMap, d::CSVData)
    return """
        csvstring = `$(d.csvstring)`
        processeddata = [keplerGl.processCsvData(csvstring)]

        // Create dataset in the format addDataToMap expects
        // NOTE: Use 'rows', not 'allData' for addDataToMap!
        const datasetToAdd = {
            info: {
                id: '$(d.id)',
                label: '$(d.id)'
            },
            data: {
                fields: processeddata[0].fields,
                rows: processeddata[0].rows
            }
        };

        newDatasets.push(datasetToAdd);
    """
end


function generate_process_string(m::KeplerGLMap, d::GeoJSONData)
    return """
        geojson = $(d.json)
        processeddata = [keplerGl.processGeojson(geojson)]

        // for debugging
        //console.log(processeddata)

        // match id with old datasets
        newDataset = processeddata.map((d, i) => ({
        version: '$(m.config[:version])',
        data: {
            id: '$(d.id)',
            label: '$(d.id)',
            allData: d.rows,
            fields: d.fields
        }
        }));

        newDatasets.push(newDataset[0]);

        // for debugging
        //console.log(newDataset)
    """
end
