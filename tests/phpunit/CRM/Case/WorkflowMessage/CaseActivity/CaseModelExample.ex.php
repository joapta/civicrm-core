<?php
class CRM_Case_WorkflowMessage_CaseActivity_CaseModelExample extends \Civi\WorkflowMessage\WorkflowMessageExample {

  /**
   * @inheritDoc
   */
  public function getExamples(): iterable {
    yield [
      'name' => "workflow/{$this->wfName}/{$this->exName}",
      'title' => ts('Case Activity (Class-style example)'),
      'tags' => ['phpunit', 'preview'],
    ];
  }

  /**
   * @inheritDoc
   */
  public function build(array &$example): void {
    $alex = \Civi\Test::example('workflow/generic/Alex');
    $example['data'] = $this->extend($alex['data'], [
      'workflow' => $this->wfName,
      'modelProps' => [
        'contact' => [
          'role' => 'myrole',
        ],
        'isCaseActivity' => 1,
        'clientId' => 101,
        'activityTypeName' => 'Follow up',
        'activityFields' => [
          [
            'label' => 'Case ID',
            'type' => 'String',
            'value' => '1234',
          ],
        ],
        'activitySubject' => 'Test 123',
        'activityCustomGroups' => [],
        'idHash' => 'abcdefg',
      ],
    ]);
    $example['asserts'] = [
      'default' => [
        ['for' => 'subject', 'regex' => '/\[case #abcdefg\] Test 123/'],
        ['for' => 'text', 'regex' => '/Your Case Role\(s\) : myrole/'],
      ],
    ];
  }

}