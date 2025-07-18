import { Octokit } from '@octokit/rest';
import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';

const octokit = new Octokit({
  auth: process.env.GITHUB_TOKEN,
});

const [owner, repo] = process.env.GITHUB_REPOSITORY.split('/');
const trackingFile = '.github/todo-tracking.json';

// Load or create tracking data
function loadTracking() {
  try {
    if (fs.existsSync(trackingFile)) {
      return JSON.parse(fs.readFileSync(trackingFile, 'utf8'));
    }
  } catch (error) {
    console.log('Error loading tracking file:', error.message);
  }
  return { todos: {} };
}

function saveTracking(data) {
  fs.mkdirSync(path.dirname(trackingFile), { recursive: true });
  fs.writeFileSync(trackingFile, JSON.stringify(data, null, 2));
}

// Generate AI title for TODO
async function generateTitle(todoText) {
  // Clean and format the TODO text
  const cleaned = todoText.replace(/^(TODO|todo):\s*/i, '').trim();
  if (!cleaned) {
    return 'TODO: Empty comment';
  }

  // Take first 8 words and truncate if needed
  const words = cleaned.split(' ').slice(0, 8);
  const shortText = words.join(' ');

  // Add ellipsis if truncated
  const title = shortText.length < cleaned.length ? `${shortText}...` : shortText;

  return `TODO: ${title}`;
}

// Find all TODO comments in the codebase
function findTodos() {
  const todos = [];
  const extensions = ['.js', '.ts', '.jsx', '.tsx', '.py', '.java', '.cpp', '.c', '.h', '.cs', '.rb', '.go', '.rs', '.php', '.swift', '.kt', '.yml', '.yaml', '.json', '.md', '.nix'];

  function scanDirectory(dir) {
    if (dir.includes('node_modules') || dir.includes('.git') || dir.includes('dist') || dir.includes('build') || dir.includes('.github/workflows')) {
      return;
    }

    try {
      const items = fs.readdirSync(dir);

      for (const item of items) {
        const fullPath = path.join(dir, item);
        const stat = fs.statSync(fullPath);

        if (stat.isDirectory()) {
          scanDirectory(fullPath);
        } else if (extensions.some(ext => item.endsWith(ext))) {
          try {
            const content = fs.readFileSync(fullPath, 'utf8');
            const lines = content.split('\n');

            lines.forEach((line, index) => {
              // More precise regex for TODO comments
              // Matches: // TODO: text, /* TODO: text, # TODO: text, * TODO: text, <!-- TODO: text
              // But NOT: variable names, template literals, or other code constructs
              const todoMatch = line.match(/^\s*(?:\/\/|\/\*|#|\*|<!--)\s*(TODO|todo):\s*(.+?)(?:\*\/|-->)?$/);

              if (todoMatch && todoMatch[2]) {
                const fullComment = todoMatch[2].trim();

                // Skip if this looks like code (contains template literals, function calls, etc.)
                if (fullComment.includes('${') ||
                    fullComment.includes('JSON.stringify') ||
                    fullComment.includes('console.') ||
                    fullComment.match(/\w+\(/)) {
                  return;
                }

                const todoText = `${todoMatch[1]}: ${fullComment}`;

                // Clean up any template literals or special characters that might cause issues
                const cleanComment = fullComment.replace(/`/g, "'").replace(/\$\{[^}]*\}/g, '[template]');

                const todoId = `${fullPath}:${index + 1}:${todoText}`;
                todos.push({
                  id: todoId,
                  file: fullPath,
                  line: index + 1,
                  text: todoText,
                  comment: cleanComment
                });

                console.log(`Found TODO: ${todoText} at ${fullPath}:${index + 1}`);
              }
            });
          } catch (error) {
            console.log(`Error reading file ${fullPath}:`, error.message);
          }
        }
      }
    } catch (error) {
      console.log(`Error scanning directory ${dir}:`, error.message);
    }
  }

  scanDirectory('.');
  return todos;
}

// Create issue for TODO
async function createIssueForTodo(todo) {
  console.log('Creating issue for TODO:', JSON.stringify(todo, null, 2));

  const title = await generateTitle(todo.text);
  console.log('Generated title:', title);

  const body = `${todo.comment}\n\n**Location:** \`${todo.file}:${todo.line}\`\n\n_This issue was automatically created from a TODO comment._`;
  console.log('Generated body:', body);

  try {
    const response = await octokit.rest.issues.create({
      owner,
      repo,
      title,
      body,
      labels: ['todo', 'automated']
    });

    console.log(`Created issue #${response.data.number} for TODO: ${todo.text}`);
    return response.data.number;
  } catch (error) {
    console.error('Error creating issue:', error);
    return null;
  }
}

// Close issue
async function closeIssue(issueNumber) {
  try {
    await octokit.rest.issues.update({
      owner,
      repo,
      issue_number: issueNumber,
      state: 'closed'
    });
    console.log(`Closed issue #${issueNumber}`);
  } catch (error) {
    console.error(`Error closing issue #${issueNumber}:`, error);
  }
}

// Remove TODO comment from file
function removeTodoFromFile(todo) {
  try {
    const content = fs.readFileSync(todo.file, 'utf8');
    const lines = content.split('\n');

    // Remove the TODO line
    lines.splice(todo.line - 1, 1);

    fs.writeFileSync(todo.file, lines.join('\n'));
    console.log(`Removed TODO from ${todo.file}:${todo.line}`);
    return true;
  } catch (error) {
    console.error(`Error removing TODO from ${todo.file}:`, error);
    return false;
  }
}

// Main function
async function main() {
  const eventName = process.env.GITHUB_EVENT_NAME;
  const tracking = loadTracking();

  if (eventName === 'push') {
    console.log('Processing push event...');

    const currentTodos = findTodos();
    const currentTodoIds = new Set(currentTodos.map(t => t.id));
    const trackedTodoIds = new Set(Object.keys(tracking.todos));

    // Create issues for new TODOs
    for (const todo of currentTodos) {
      if (!trackedTodoIds.has(todo.id)) {
        const issueNumber = await createIssueForTodo(todo);
        if (issueNumber) {
          tracking.todos[todo.id] = {
            issueNumber,
            file: todo.file,
            line: todo.line,
            text: todo.text
          };
        }
      }
    }

    // Close issues for removed TODOs
    for (const todoId of trackedTodoIds) {
      if (!currentTodoIds.has(todoId)) {
        const todoData = tracking.todos[todoId];
        await closeIssue(todoData.issueNumber);
        delete tracking.todos[todoId];
      }
    }

    saveTracking(tracking);

    // Commit tracking file if it changed
    try {
      execSync('git add .github/todo-tracking.json');
      execSync('git commit -m "Update TODO tracking [skip ci]"');
      execSync('git push');
    } catch (error) {
      console.log('No changes to commit or error committing:', error.message);
    }

  } else if (eventName === 'issues') {
    console.log('Processing issue event...');

    const eventData = JSON.parse(fs.readFileSync(process.env.GITHUB_EVENT_PATH, 'utf8'));
    const issueNumber = eventData.issue.number;

    // Find TODO associated with this issue
    const todoEntry = Object.entries(tracking.todos).find(([_, data]) => data.issueNumber === issueNumber);

    if (todoEntry) {
      const [todoId, todoData] = todoEntry;

      // Remove TODO from code
      const success = removeTodoFromFile(todoData);

      if (success) {
        delete tracking.todos[todoId];
        saveTracking(tracking);

        // Commit the changes
        try {
          execSync(`git add "${todoData.file}"`);
          execSync('git add .github/todo-tracking.json');
          execSync(`git commit -m "Remove TODO comment (issue #${issueNumber} closed) [skip ci]"`);
          execSync('git push');
        } catch (error) {
          console.error('Error committing TODO removal:', error);
        }
      }
    }
  }
}

main().catch(console.error);
