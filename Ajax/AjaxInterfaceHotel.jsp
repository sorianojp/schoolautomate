<%@ page language="java" import="utility.*"%>
<%
response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1


String strMethodRef = request.getParameter("methodRef");
if(strMethodRef == null) {
	response.getWriter().print("Error Msg : Invalid Method Call");
	return;
}

String strRetResult = null;
String strResult2 = null;
String strTemp = null;
AjaxInterface AI    = new AjaxInterface();

hmsOperation.RestPOS hmsPOS= new hmsOperation.RestPOS();
hmsOperation.RSFoodRequest rsFood = new hmsOperation.RSFoodRequest();

DBOperation dbOP    = null;
WebInterface WI     = new WebInterface(request);
boolean bolNoUIDChecking = false;
try {
	dbOP = new DBOperation();
	
	int iMethodRef = Integer.parseInt(strMethodRef);
	switch(iMethodRef) {
		case 3: //Load items from selected category
			strRetResult = hmsPOS.ajaxLoadCategoryItems(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+hmsPOS.getErrMsg();
			break;
			
		case 4: // add new item
			strRetResult = hmsPOS.getItemInfo(dbOP, request);
			
			if(strRetResult == null){
				strRetResult = "Error Msg : "+hmsPOS.getErrMsg();
				break;
			}

			strRetResult = hmsPOS.constructOrderTable(request);
			strRetResult += "##########";
			strRetResult += hmsPOS.constructSummary(dbOP,request);
		break;
		
		case 5: //
			strTemp = hmsPOS.constructOrderTable(request);		
		 	if(strTemp == null){
				strRetResult = "Error Msg : "+hmsPOS.getErrMsg();			
				break;			
			}
			strRetResult = strTemp;			
			strRetResult += "##########";
			
			strTemp = hmsPOS.constructSummary(dbOP,request);
		 	if(strTemp == null){
				strRetResult = "Error Msg : "+hmsPOS.getErrMsg();			
				break;			
			}			
			strRetResult += strTemp;
			strRetResult += "##########";

			strTemp = hmsPOS.ajaxLoadCategories(dbOP, request);
		 	if(strTemp == null){
				strRetResult = "Error Msg : "+hmsPOS.getErrMsg();			
				break;			
			}						
			strRetResult += strTemp;
		break;
				
		case 6: // removing item
			strRetResult = hmsPOS.removeItem(dbOP, request);			
			if(strRetResult == null){
				strRetResult = "Error Msg : "+hmsPOS.getErrMsg();			
				break;			
			}
			strRetResult = hmsPOS.constructOrderTable(request);		
			strRetResult += "##########";
			strRetResult += hmsPOS.constructSummary(dbOP, request);			
		break;
		
		case 7: //Load items from selected category			
			strRetResult = rsFood.ajaxLoadFoodItems(dbOP, request);
 			if(strRetResult == null)
				strRetResult = "Error Msg : "+ rsFood.getErrMsg();
		break;

		case 18: // load the categories in the restaurant
			strRetResult = hmsPOS.ajaxLoadCategories(dbOP, request);
			if(strRetResult == null)
				strRetResult = "Error Msg : "+hmsPOS.getErrMsg();
 			break;
		case 402: //Load items from selected category
			strRetResult = rsFood.ajaxLoadRoomFoodItems(dbOP, request);
			if(strRetResult == null)
					strRetResult = "Error Msg : "+ rsFood.getErrMsg();
				bolNoUIDChecking = true;
			break;		
	}
}
catch(Exception e) {
	strRetResult = "";
}
//clean up here. 
if(dbOP != null)
	dbOP.cleanUP();
////write obj here.. 
if(strRetResult == null)
	strRetResult = "Error Msg : "+AI.getErrMsg();

//System.out.println("Err Msg :"+strRetResult+":");

//if logged out, I must put relaod to 1
if(request.getSession(false).getAttribute("userIndex") == null && !bolNoUIDChecking)
	strRetResult = "Reload";

response.getWriter().print(strRetResult);

%>