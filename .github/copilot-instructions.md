# E-Imunisasi AI Coding Agent Instructions

## Project Overview

**E-Imunisasi** is a Flutter mobile app for managing children's immunization schedules and records. It uses **Clean Architecture with BLoC pattern**, Supabase backend, and includes both Midtrans and Stripe payment integration.

## Architecture Patterns

### Core Structure

- **Feature-based organization**: Each feature in `lib/features/` follows `data/logic/presentation` structure
- **Clean Architecture layers**: Repository pattern with data sources, use cases via BLoCs/Cubits, and UI separation
- **Dependency Injection**: Uses `get_it` + `injectable` with `@Injectable()` annotations

### BLoC State Management

- **BLoC for complex state**: Multi-entity operations (appointments, calendar, health workers)
- **Cubit for simple forms**: Authentication forms, profile updates
- **State pattern**: Uses `Formz` for form validation states (`FormzSubmissionStatus.inProgress/success/failure`)
- **Error handling**: Emit failure states with error messages, show via `snackbarCustom()`

Example BLoC pattern:

```dart
@injectable
class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentRepository repository;

  AppointmentBloc(this.repository) : super(AppointmentState()) {
    on<LoadAppointmentsEvent>(_onLoadAppointments);
  }

  void _onLoadAppointments(LoadAppointmentsEvent event, Emitter emit) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      final appointments = await repository.getAppointments();
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        appointments: appointments,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
```

### Navigation & Routing

- **GoRouter with nested routes**: Main router in `lib/routers/router.dart`
- **Route path constants**: Centralized in `lib/routers/route_paths/`
- **Sub-route issue**: Sub-route paths must NOT start/end with `/` - use relative paths only
- **Authentication flow**: Root route handles auth state via `BlocConsumer<AuthenticationBloc>`

## Development Workflows

### Code Generation

```bash
# Generate injectable dependencies
dart run build_runner build --delete-conflicting-outputs

# Run tests with coverage
flutter test --coverage
```

### Build & Deploy

- **Fastlane setup**: Android deployment via `android/fastlane/`
- **Multiple payment variants**: Separate APKs for Midtrans/Stripe via build flavors
- **Build commands**: Uses `flutter build appbundle` for release builds

### Testing Patterns

- **BLoC testing**: Use `bloc_test` package with `build/act/expect` pattern
- **Mocking**: `@GenerateMocks([Repository])` with `mockito`
- **Test structure**: Mirror `lib/` structure in `test/`
- **Repository testing**: Use `mock_supabase_http_client` for Supabase mocking

## Key Conventions

### Repository Pattern

```dart
@injectable
class AuthRepository {
  final SupabaseClient supabaseClient;
  final SharedPreferences sharedPreferences;

  AuthRepository(this.supabaseClient, this.sharedPreferences);

  Future<List<Model>> getItems() async {
    final response = await supabaseClient.from('table_name').select();
    return response.map((json) => Model.fromJson(json)).toList();
  }
}
```

### Form Validation

- **Formz models**: Custom validation classes (Email, Password, Phone) in `data/models/`
- **State management**: Track form validity and submission status
- **Error display**: Show validation errors immediately, submission errors via snackbar

### Asset Management

- **Images**: Store in `assets/images/`, reference via `AppAssets` constants
- **Fonts**: Nunito font family with Regular/Bold/Italic variants
- **Environment**: Use `flutter_dotenv` for Supabase/Stripe keys in `.env`

## Integration Points

### Supabase Backend

- **Authentication**: OAuth + email/password via `supabase_flutter`
- **Database**: PostgreSQL with row-level security
- **Storage**: File uploads for profile images
- **Real-time**: Auth state changes via `onAuthStateChange` stream

### External Services

- **Payments**: Dual integration (Stripe + Midtrans) with separate build variants
- **Notifications**: Local notifications via `flutter_local_notifications`
- **Storage**: Hive for local data caching (calendar activities)

### Error Handling

- Always catch repository errors and emit failure states
- Use `snackbarCustom()` for user-facing error messages
- Log errors with `debugPrint()` in debug mode via `AppBlocObserver`

## Anti-Patterns to Avoid

- Don't use `/` prefix/suffix in GoRouter sub-routes
- Don't bypass repository layer - always use dependency injection
- Don't handle auth state in individual screens - use global `AuthenticationBloc`
- Don't hardcode API endpoints - use environment variables
- Don't skip error states in BLoCs - always handle failure cases
