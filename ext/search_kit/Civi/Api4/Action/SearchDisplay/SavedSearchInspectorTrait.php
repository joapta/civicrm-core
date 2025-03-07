<?php

namespace Civi\Api4\Action\SearchDisplay;

use Civi\Api4\Query\SqlExpression;
use Civi\Api4\SavedSearch;
use Civi\Api4\Utils\CoreUtil;

/**
 * Trait for requiring a savedSearch as a param plus util functions for inspecting it.
 *
 * @method $this setSavedSearch(array|string $savedSearch)
 * @method array|string getSavedSearch()
 * @package Civi\Api4\Action\SearchDisplay
 */
trait SavedSearchInspectorTrait {

  /**
   * Either the name of the savedSearch or an array containing the savedSearch definition (for preview mode)
   * @var string|array
   * @required
   */
  protected $savedSearch;

  /**
   * @var array{select: array, where: array, having: array, orderBy: array, limit: int, offset: int, checkPermissions: bool, debug: bool}
   */
  protected $_apiParams;

  /**
   * @var \Civi\Api4\Query\Api4SelectQuery
   */
  private $_selectQuery;

  /**
   * @var array
   */
  private $_selectClause;

  /**
   * If SavedSearch is supplied as a string, this will load it as an array
   * @throws \API_Exception
   * @throws \Civi\API\Exception\UnauthorizedException
   */
  protected function loadSavedSearch() {
    if (is_string($this->savedSearch)) {
      $this->savedSearch = SavedSearch::get(FALSE)
        ->addWhere('name', '=', $this->savedSearch)
        ->execute()->single();
    }
    $this->_apiParams = ($this->savedSearch['api_params'] ?? []) + ['select' => [], 'where' => [], 'join' => [], 'having' => []];
  }

  /**
   * Returns field definition for a given field or NULL if not found
   * @param $fieldName
   * @return array|null
   */
  protected function getField($fieldName) {
    return $this->getQuery() ? $this->getQuery()->getField($fieldName, FALSE) : NULL;
  }

  /**
   * @param $joinAlias
   * @return array{entity: string, alias: string, table: string, bridge: string|NULL}|NULL
   */
  protected function getJoin($joinAlias) {
    return $this->getQuery()->getExplicitJoin($joinAlias);
  }

  /**
   * @return array{entity: string, alias: string, table: string, bridge: string|NULL}[]
   */
  protected function getJoins() {
    return $this->getQuery() ? $this->getQuery()->getExplicitJoins() : [];
  }

  /**
   * @return \Civi\Api4\Query\Api4SelectQuery
   */
  private function getQuery() {
    if (!$this->_selectQuery && !empty($this->savedSearch['api_entity'])) {
      $api = \Civi\API\Request::create($this->savedSearch['api_entity'], 'get', $this->savedSearch['api_params']);
      $this->_selectQuery = new \Civi\Api4\Query\Api4SelectQuery($api);
    }
    return $this->_selectQuery;
  }

  /**
   * Returns the select clause enhanced with metadata
   *
   * @return array{fields: array, expr: SqlExpression, dataType: string}[]
   */
  protected function getSelectClause() {
    if (!isset($this->_selectClause)) {
      $this->_selectClause = [];
      foreach ($this->_apiParams['select'] as $selectExpr) {
        $expr = SqlExpression::convert($selectExpr, TRUE);
        $item = [
          'fields' => [],
          'expr' => $expr,
          'dataType' => $expr->getDataType(),
        ];
        foreach ($expr->getFields() as $fieldName) {
          $fieldMeta = $this->getField($fieldName);
          if ($fieldMeta) {
            $item['fields'][] = $fieldMeta;
          }
        }
        if (!isset($item['dataType']) && $item['fields']) {
          $item['dataType'] = $item['fields'][0]['data_type'];
        }
        $this->_selectClause[$expr->getAlias()] = $item;
      }
    }
    return $this->_selectClause;
  }

  /**
   * @param string $key
   * @return array{fields: array, expr: SqlExpression, dataType: string}|NULL
   */
  protected function getSelectExpression($key) {
    return $this->getSelectClause()[$key] ?? NULL;
  }

  /**
   * Determines if a column belongs to an aggregate grouping
   * @param string $fieldPath
   * @return bool
   */
  private function canAggregate($fieldPath) {
    $apiParams = $this->savedSearch['api_params'] ?? [];
    $field = $this->getField($fieldPath);

    // If the query does not use grouping or the field doesn't exist, never
    if (empty($apiParams['groupBy']) || !$field) {
      return FALSE;
    }
    // If the column is used for a groupBy, no
    if (in_array($fieldPath, $apiParams['groupBy'])) {
      return FALSE;
    }

    // If the entity this column belongs to is being grouped by id, then also no
    $suffix = strstr($fieldPath, ':') ?: '';
    $idField = substr($fieldPath, 0, 0 - strlen($field['name'] . $suffix)) . CoreUtil::getIdFieldName($field['entity']);
    return !in_array($idField, $apiParams['groupBy']);
  }

}
