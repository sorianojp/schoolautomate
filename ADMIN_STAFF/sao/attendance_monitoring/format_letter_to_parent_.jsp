<%@ page language="java" import="utility.*, enrollment.AttendanceMonitoringCDD, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script language="javascript" src ="../../../jscript/common.js" ></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
function ReloadPage()
{
	document.form_.submit();
}

function UpdateStatusClaimed(strAction, strStat){
	var strTemp = "";
	if(strStat == '1')
		strTemp = "Claimed?";
	else
		strTemp = "Unclaimed?";
	
	if(!confirm("Do you want to set the status to "+strTemp))
		return;
	
	document.form_.status_.value = strStat;
	document.form_.page_action.value = strAction;
	document.form_.submit();
}

function UpdateStatusDropped(strAction, strStat){
	var strTemp = "";
	if(strStat == '1')
		strTemp = "drop";
	else
		strTemp = "undrop";

	if(!confirm("Do you want to "+strTemp+" the student in this subject?"))
		return;
	
	document.form_.drop_reason.value = prompt("Reason");

	document.form_.status_.value = strStat;
	document.form_.page_action.value = strAction;
	document.form_.submit();
}

function ChangeMaxAbsences(){
	if(!confirm("Do you want to change change the value of maximum absences?"))
		return;
	
	document.form_.page_action.value = '9';
	document.form_.submit();
}

function PageAction(strAction, strInfoIndex){
	if(strAction == '0'){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
		
	document.form_.page_action.value = strAction;
	document.form_.submit();


}

function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>
<style type="text/css">
body{
	font-family:Verdana, Geneva, sans-serif;
	font-size:8pt;
	margin:1.5in 0.7in 0in 0.7in;
}


#bodyletter{
	height:6.3in;

}

.paragraph{
	margin:15px 0px 15px 0px;
}

</style>
</head>
<body onLoad="window.print(); window.close();">
<%
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("STUDENT AFFAIRS-STUDENT TRACKER"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("STUDENT AFFAIRS"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"STUDENT AFFAIRS-STUDENT TRACKER","attendance_monitoring.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
Vector vRetResult = new Vector();
String strParentName = null;
String strAddress = null;

AttendanceMonitoringCDD attendanceCDD = new AttendanceMonitoringCDD();

if(WI.fillTextValue("user_index").length() > 0){
	vRetResult = attendanceCDD.getInfoForLetterPrinting(dbOP,request);
	if(vRetResult == null)
		strErrMsg = attendanceCDD.getErrMsg();	
	else {
		String strSQLQuery = " select f_name, m_name,con_per_name, res_house_no, res_city, res_provience, " + //4-7
        	" res_country, res_zip from info_contact " +
        	" left join info_parent on (info_parent.user_index = info_contact.user_index) " +
        	" where info_contact.user_index = " + WI.fillTextValue("user_index") ;
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			if(rs.getString(1) != null)
				strParentName = rs.getString(1);
			else if(rs.getString(2) != null)
				strParentName = rs.getString(2);
			else if(rs.getString(3) != null)
				strParentName = rs.getString(3);
			strAddress = rs.getString(4);
			if(strAddress != null) {
				if(rs.getString(5) != null) {
					strAddress = strAddress + "<br>"+rs.getString(5);
					if(rs.getString(6) != null) 
						strAddress = strAddress + ", "+rs.getString(6);
					if(rs.getString(7) != null) 
						strAddress = strAddress + " - "+rs.getString(7);
				}
			}
		}
		rs.close();
	}
}

if(strErrMsg != null){
%>
<div><font color="#FF0000"><strong><%=strErrMsg%></strong></font></div>


<%}if(vRetResult != null && vRetResult.size() > 0){%>

<div id="bodyletter">
<div class="paragraph">
	<%=WI.getTodaysDate(6)%><br><br>
<strong><%=strParentName%></strong>
	<%if(strAddress != null) {%>
		<br><%=strAddress%>
	<%}%>
</div>

<div class="paragraph">Dear Sir / Ma'am,</div>


<div class="paragraph">	
		We would like to apoligize for the informality of this letter but this is the fastest way we can reach 
		you. We would like to inform you that your son / daughter <strong><%=WebInterface.formatName((String)vRetResult.elementAt(1),(String)vRetResult.elementAt(2),(String)vRetResult.elementAt(3), 7)%> (<%=(String)vRetResult.elementAt(0)%>)</strong> incurred several absences in the following subject(s):	</td>
</div>

<%
for(int i = 0; i < vRetResult.size(); i+=5){
%>

<div><strong><%=(String)vRetResult.elementAt(i + 4)%></strong></div>
<%}%>

<div class="paragraph">	
		His / her classcard(s) is (are) currently with the Student Affairs Office (SAO) located at the FAME Building. 
		In this regard, we would like to invite you to visit us at the SAO to discuss your son's / daughter's standing in the above mentioned subject(s).	
</div>

<div class="paragraph">
		We respectfully recommend that you personally visit us but if it is impossible for you to do so,
		please fill up the return slip below.	
</div>

<div class="paragraph"><br />Respectfully yours, <br /><br /></div>
<div><strong><%=CommonUtil.getNameForAMemberType(dbOP,"Coordinator, Student Affairs",7)%></strong></div>
<div>Coordinator, Student Affairs<br />
  <br /></div>

<div>Noted by:</div>
<div style="background-image:url(fvas_signature.png); background-repeat:no-repeat; height:97px; padding-top:47px; background-position: 40px 0px; \">
<strong><%=CommonUtil.getNameForAMemberType(dbOP,"VP for Administration",7)%></strong><br>
VP, Administration/Student Affairs<br /><br />
Please bring this letter with you when you visit us. Thank you for you cooperation.
</div>



</div>
<div  class="paragraph"><strong><%=WebInterface.formatName((String)vRetResult.elementAt(1),(String)vRetResult.elementAt(2),(String)vRetResult.elementAt(3), 7)%> (<%=(String)vRetResult.elementAt(0)%>)</strong></div>


<%}%>

  

</body>
</html>
<%
dbOP.cleanUP();
%>
