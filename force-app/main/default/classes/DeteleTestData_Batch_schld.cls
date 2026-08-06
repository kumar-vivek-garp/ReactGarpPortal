public class DeteleTestData_Batch_schld implements Schedulable{
public void execute(SchedulableContext sc) {
      DeteleTestData_Batch batch = new DeteleTestData_Batch(); 
      database.executebatch(batch);
   }
}