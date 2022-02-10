module.exports = {
    'env': {
        'browser': true,
        'es2021': true,
        'node': true,
    },
    'extends': [
        'google',
    ],
    'parserOptions': {
        'ecmaVersion': 12,
        'sourceType': 'module',
    },
    'rules': {
        'camelcase': 'off',
        'require-jsdoc': 'off',
        'no-unused-vars': 'off',
        'new-cap': 'off',
        'prefer-rest-params': 'off'
    },
};
