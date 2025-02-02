<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Guidance Service Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage(strShowStat){
	document.form_.show_statistics.value = strShowStat;
	document.form_.submit();
}
function ViewStudent(strField) {
	var strIsBasic = "0";
	if(document.form_.is_basic.checked)
		strIsBasic = "1";

	var pgURL = "./guidance_services_print.jsp?field="+strField+
	"&sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value+
	"&semester="+document.form_.semester.value;
if(document.form_.c_index)
	pgURL += "&c_index="+document.form_.c_index.value;
if(document.form_.course_index)
	pgURL += "&course_index="+document.form_.course_index.value;

pgURL+=
	"&year_level="+document.form_.year_level.value+
	"&is_basic="+strIsBasic+
	"&stud_id="+document.form_.stud_id.value;
	var win=window.open(pgURL,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AjaxMapName() {
		var strCompleteName = document.form_.stud_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=-1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.stud_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>
<%@ page language="java" import="utility.*,osaGuidance.GDTrackerServices,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");	
	if (strSchCode == null)
		strSchCode = "";

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-Guidance-Reports-Other","guidance_services_report.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%return;
	}

	GDTrackerServices guidanceServ =new GDTrackerServices ();
	Vector vRetResult = null;
	
	if(WI.fillTextValue("show_statistics").length() > 0){		
		vRetResult = guidanceServ.generateStudentSevices(dbOP, request,2);
		if(vRetResult == null)
		   strErrMsg = guidanceServ.getErrMsg();		
	}
	String[] astrField = {"", "field_1", "field_2", "field_3", "field_8", "field_9", "field_10",
                "field_11", "field_24", "field_25", "field_29", "field_32", "field_33", "field_34",
                "field_35", "field_36", "field_37", "field_41", "field_44"};          
	
	String[] astrServices = {"", "Counseling", "Individual", "Group Counseling", "Testing",
                "Individual Inventory", "Referral", "Orientation", "Job Enhancement Program", "Module 1",
                "Module 2", "Job Interview Simulation", "i-Trabajo", "Directory of Graduates",
                "Career Orientation", "Information", "Learning Session", "Fora", "Peer Facilitating Program"
            };
%>
<body>
<form action="guidance_services_report.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          GUIDANCE SERVICES PAGE ::::</strong></font></div></td>
    </tr>
	<tr><td width="88%" height="25" style="padding-left:30px;"><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
	    <td width="12%" align="right">
		<a href="main.jsp"><img src="../../../../../images/go_back.gif" border="0"></a>		</td>
	</tr>
</table>  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	    <td height="25">&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("is_basic");
		boolean bolIsBasic = false;
		if(strTemp.equals("1")){
			strErrMsg = "checked";
			bolIsBasic = true;
		}else
			strErrMsg = "";
		%>
	    <td colspan="2"><input type="checkbox" name="is_basic" value="1" <%=strErrMsg%> onClick="ReloadPage('');">Click to view basic education students.</td>
	    </tr>
	<tr>
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">SY-Term</td>
		<td>
		<%	strTemp = WI.fillTextValue("sy_from");
			if(strTemp.length() ==0) 
				strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
		%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'> 
		<%	strTemp = WI.fillTextValue("sy_to");
			if(strTemp.length() ==0) 
				strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
		%>
        - 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
	  &nbsp;	  
	   <select name="semester">
	<%	strTemp = WI.fillTextValue("semester");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
		if(strTemp.equals("0"))	   
			strErrMsg = "selected";
		else
			strErrMsg = "";
	%>
	<option value="0" <%=strErrMsg%>>Summer</option>
	<%	if(strTemp.equals("1"))	   
			strErrMsg = "selected";
		else
			strErrMsg = "";
	%>
	<option value="1" <%=strErrMsg%>>1st Sem</option>
	<%	if(strTemp.equals("2"))	   
			strErrMsg = "selected";
		else
			strErrMsg = "";
	%>
	<option value="2" <%=strErrMsg%>>2nd Sem</option>
	<%	if(strTemp.equals("3"))	   
			strErrMsg = "selected";
		else
			strErrMsg = "";
	%>
	<option value="3" <%=strErrMsg%>>3rd Sem</option>
	<%	if(strTemp.equals("4"))	   
			strErrMsg = "selected";
		else
			strErrMsg = "";
	%>
	<option value="4" <%=strErrMsg%>>4th Sem</option>
        </select>		</td>
	</tr>
<%
if(!bolIsBasic){
%>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>College</td>
	    <td>
			<select name="c_index" onChange="ReloadPage('');" style="width:300px;">
				<option value="">Select Any</option>
				<%=dbOP.loadCombo("c_index"," c_name "," from college where is_del = 0 ",WI.fillTextValue("c_index"), false)%>
			</select>		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Course</td>
	    <td>
			<select name="course_index" onChange="ReloadPage('');" style="width:300px;">
				<option value="">Select Any</option>
				<%	strTemp = " from COURSE_OFFERED where IS_VALID =1 and IS_OFFERED = 1 ";
					if(WI.fillTextValue("c_index").length() > 0)
						strTemp += " and c_index = "+WI.fillTextValue("c_index");
					strTemp += " order by course_code";
				%>
				<%=dbOP.loadCombo("course_index"," course_code, course_name ",strTemp,WI.fillTextValue("course_index"), false)%>
			</select>		</td>
	</tr>
<%}%>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Year Level</td>
	    <td>
		<select name="year_level" onChange="ReloadPage('');">
			<option value="">Select Any</option>
			<%	
			if(!bolIsBasic){
				strTemp = WI.fillTextValue("year_level");
				if(strTemp.equals("1"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>
			<option value="1" <%=strErrMsg%>>1st Year</option>
			<%	if(strTemp.equals("2"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>
			<option value="2" <%=strErrMsg%>>2nd Year</option>
			<%	if(strTemp.equals("3"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>
			<option value="3" <%=strErrMsg%>>3rd Year</option>
			<%	if(strTemp.equals("4"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>
			<option value="4" <%=strErrMsg%>>4th Year</option>
			<%	if(strTemp.equals("5"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>
			<option value="5" <%=strErrMsg%>>5th Year</option>
			<%	if(strTemp.equals("6"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
			%>
			<option value="6" <%=strErrMsg%>>6th Year</option>
			<%}else{%><%=dbOP.loadCombo("g_level","level_name"," from BED_LEVEL_INFO order by g_level",WI.fillTextValue("year_level"),false)%><%}%>
		</select>		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>ID Number</td>
	    <td>
		<input name="stud_id" type="text" size="16" class="textbox" value="<%=WI.fillTextValue("stud_id")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();"> 
	  &nbsp; <label id="coa_info" style="position:absolute; width:400px;"></label> 
		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>
		<a href="javascript:ReloadPage('1');"><img src="../../../../../images/form_proceed.gif" border="0"></a>		</td>
	</tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td>&nbsp;</td></tr>
	<tr>
		<td height="22" bgcolor="#CCCCCC" align="center" class="thinborderBOTTOM" style="font-weight:bold">
		SUMMARY OF STUDENT SERVICES</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr>
		<td colspan="4" height="20">&nbsp;</td>
	</tr>
	<%for(int i=1; i<astrServices.length; ++i){%>	
	<tr>
	   <td width="11%" height="30">&nbsp;</td>
	   <td height="30" colspan="2" style="font-size:18px;
	   <%if(i==2 || i==3 || i==9 || i==10|| i==11 ||i==12 || i==13 ||i==16 || i==17){%>
        padding-left:50px;<%}%>"><%=astrServices[i]%></td> 
	   <%  String strFieldName =null;
	       for(int x=0; x<vRetResult.size();x+=3){         
				 if(vRetResult.elementAt(x).equals(astrServices[i])){	
				    strFieldName =(String) vRetResult.elementAt(x+1);  
					strTemp =(String) vRetResult.elementAt(x+2);
					break;			   			   
				 }else{
				 	strFieldName = astrField[i];	
					strTemp ="0"; 
				}
		   }
	   %>		
	   <td width="55%" style="font-size:18px;">	   
	   <%=strTemp%>
	   <%
	   if(Integer.parseInt(WI.getStrValue(strTemp,"0")) > 0){
	   %>
	   <a href="javascript:ViewStudent('<%=strFieldName%>')">
	   <img src="../../../../../images/view.gif" border="0"></a>
	   <%}%>
	   </td>
	</tr>
	<%}//end of vRetResult loop%>    
</table>
<%}//end of vRetResult!=null && vRetResult.size()>0%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td>&nbsp;</td></tr>
	<tr bgcolor="#A49A6A"><td height="25">&nbsp;</td></tr>
</table>
<input type="hidden" name="show_statistics" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>