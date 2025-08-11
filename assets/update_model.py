import json
import os
from pathlib import Path

def update_knowledge_book_model(input_file, output_dir):
    # Read the input JSON file
    with open(input_file, 'r') as f:
        data = json.load(f)

    # Ensure output directory exists
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Define the resource pack structure
    models_dir = output_dir / 'assets' / 'minecraft' / 'models' / 'item'
    models_dir.mkdir(parents=True, exist_ok=True)

    # Create the base knowledge_book.json in the new format
    base_model = {
        "model": {
            "type": "minecraft:model",
            "model": "minecraft:item/knowledge_book"
        }
    }
    with open(models_dir / 'knowledge_book.json', 'w') as f:
        json.dump(base_model, f, indent=2)

    # Process each override
    overrides = data.get('overrides', [])
    for override in overrides:
        custom_model_data = override['predicate']['custom_model_data']
        model_path = override['model']
        # Extract the model name from the model path (e.g., "minecraft:item/override/statue_1" -> "statue_1")
        model_name = model_path.split('/')[-1]
        # Create the model file in the new format
        new_model = {
            "model": {
                "type": "minecraft:model",
                "model": model_path
            }
        }
        # Save the model file in the appropriate directory, preserving the original path structure
        model_path_parts = model_path.split('/')
        if len(model_path_parts) > 2:
            # Create subdirectories (e.g., override/books/)
            override_dir = models_dir / '/'.join(model_path_parts[1:-1])
        else:
            override_dir = models_dir
        override_dir.mkdir(parents=True, exist_ok=True)
        with open(override_dir / f"{model_name}.json", 'w') as f:
            json.dump(new_model, f, indent=2)

        print(f"Generated model file for CMD {custom_model_data}: {override_dir / f'{model_name}.json'}")

    # Create pack.mcmeta for the resource pack
    pack_mcmeta = {
        "pack": {
            "pack_format": 22,
            "description": "Updated knowledge book models for Minecraft 1.21.4"
        }
    }
    with open(output_dir / 'pack.mcmeta', 'w') as f:
        json.dump(pack_mcmeta, f, indent=2)

    print(f"Resource pack structure created at: {output_dir}")
    print(f"Base model saved at: {models_dir / 'knowledge_book.json'}")
    print(f"Total override models generated: {len(overrides)}")

if __name__ == "__main__":
    # Example usage
    input_file = "knowledge_book.json"
    output_dir = "UpdatedKnowledgeBookResourcePack"
    update_knowledge_book_model(input_file, output_dir)