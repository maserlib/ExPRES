import setuptools

with open('README.md', 'r') as fh:
    long_description = fh.read()

setuptools.setup(
    name="ExPRES",
    version="1.2.0",
    author="Baptiste Cecconi",
    author_email="baptiste.cecconi@obspm.fr",
    description="ExPRES code library",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/maserlib/ExPRES",
    packages = ['ExPRES'],
    classifiers=[
        'Development Status :: 3 - Alpha',
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent"
    ],
    python_requires='>3.7',
    include_package_data=True
)