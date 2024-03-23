# Define the C# code for conversion
$csharpCode = @"
using System;
using System.IO;
using System.Text;
using System.Collections.Generic;

public class STLtoOBJConverter
{
    public static string Convert(string inputFile)
    {
        List<string> vertices = new List<string>();
        List<string> faces = new List<string>();

        StringBuilder objContent = new StringBuilder();

        // Read the STL file
        using (StreamReader reader = new StreamReader(inputFile))
        {
            string line;
            while ((line = reader.ReadLine()) != null)
            {
                if (line.Trim().StartsWith("vertex"))
                {
                    // Add vertices to OBJ lines
                    string[] vertexValues = line.Trim().Split(' ');
                    vertices.Add("v " + vertexValues[1] + " " + vertexValues[2] + " " + vertexValues[3]);
                }
            }
        }

        // Generate face indices
        for (int i = 1; i <= vertices.Count; i += 3)
        {
            faces.Add("f " + i + " " + (i + 1) + " " + (i + 2));
        }

        // Combine vertices and faces into OBJ content
        objContent.AppendLine("# Vertices");
        objContent.AppendLine(string.Join(Environment.NewLine, vertices));
        objContent.AppendLine("# Faces");
        objContent.AppendLine(string.Join(Environment.NewLine, faces));

        return objContent.ToString();
    }
}
"@

# Add the C# code as a type to PowerShell
Add-Type -TypeDefinition $csharpCode

# Function to convert .stl to .obj
function Convert-STLtoOBJ {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]$Path
    )
    
    begin {
        # Ensure the path is valid
        if (-not (Test-Path -LiteralPath $Path)) {
            throw "Path '$Path' not found!"
        }
    }
    
    process {
        # Get the file extension
        $extension = [System.IO.Path]::GetExtension($Path).ToLower()

        # Check if the file is .stl
        if ($extension -ne ".stl") {
            Write-Warning "File '$Path' is not an .stl file!"
            return
        }

        # Call the C# method to perform conversion
        $objContent = [STLtoOBJConverter]::Convert($Path)

        # Generate the output path with .obj extension
        $outputFile = [System.IO.Path]::ChangeExtension($Path, ".obj")

        # Write the OBJ content to the output file
        $objContent | Out-File -FilePath $outputFile -Encoding ASCII

        Write-Output "Conversion completed: $Path -> $outputFile"
    }
}

# Example usage:
# Convert-STLtoOBJ -Path "C:\path\to\file.stl"
