<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsSWU = strSchCode.startsWith("SWU");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/treelinkcss.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax2.js"></script>
<script language="JavaScript">


function PrintPage(){

	if(!confirm("Click OK to Print Page."))
		return;

	document.bgColor = "#FFFFFF";

	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	
	document.getElementById("myADTable2").deleteRow(0);

	window.print();	
}




</script>
<body>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Class program per subject","class_program_persection_term_htc.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","REPORTS",request.getRemoteAddr(), 
														"elist_page1.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
enrollment.SubjectSection SS = new enrollment.SubjectSection();
Vector vRetResult = new Vector();


String strSYFrom   = WI.fillTextValue("sy_from");
String strSYTo     = WI.fillTextValue("sy_to");
String strSemester = WI.fillTextValue("semester");

Vector vSubSecInfo = null; 
int iIndexOf = 0;
int iElemCount = 0;

String[] astrRequestedSub = {"Offered", "Requested"};
if(strSYFrom.length() > 0 && strSemester.length() > 0){

	String strCon = "";
	if(WI.fillTextValue("term_type").length() > 0)
        strCon += " and e_sub_section.term_ess = "+WI.fillTextValue("term_type");
		
	boolean bolAllowAdjustCapacity = true;
	String strCapacity = " e_sub_section.capacity ";
	strTemp = dbOP.getResultOfAQuery("select prop_val from read_property_file where prop_name = 'ADVISING_CAPACITY'", 0);
	if(strTemp == null || (strTemp != null && !strTemp.equals("1"))){
		strCapacity = " e_room_detail.total_cap ";
		bolAllowAdjustCapacity = false;
	}

		
	strTemp =
		" select distinct e_sub_section.sub_sec_index, e_sub_section.sub_index, sub_code, sub_name, " +
		" is_force_closed, studEnrolled, section, is_requested_sub, "+ strCapacity +
		" from e_sub_section "+
		" join subject on (subject.sub_index = e_sub_section.sub_index) ";
	//if(!bolAllowAdjustCapacity)
		strTemp += " join E_ROOM_ASSIGN on (E_ROOM_ASSIGN.SUB_SEC_INDEX = E_SUB_SECTION.SUB_SEC_INDEX) "+ 
			" join E_ROOM_DETAIL on (E_ROOM_DETAIL.ROOM_INDEX = E_ROOM_ASSIGN.ROOM_INDEX) ";
	strTemp += 
		" left join ( "+
		" 		select sub_sec_index as subSecIndex, count(*) as studEnrolled "+
		" 		from enrl_final_cur_list where is_valid  =1 and sy_from = "+strSYFrom+
		" 		and current_semester = "+strSemester +
		" 		group by sub_sec_index "+
		" 	)as DT_EFCL on DT_EFCL.subSecIndex = e_sub_section.sub_sec_index "+
		" where e_sub_section.is_valid = 1 and is_lec = 0 and offering_sy_from = "+strSYFrom+
		" and E_ROOM_ASSIGN.is_valid =1"+
		" and offering_sem ="+strSemester + strCon +
		" order by sub_code, section ";

	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	int iAvailSlot = 0;
	while(rs.next()) {
		vRetResult.addElement(rs.getString(1));//[0]sub_sec_index
		vRetResult.addElement(rs.getString(2));//[1]sub_index
		strTemp = rs.getString(3);
		if(rs.getInt(5) == 1)
			strTemp += "**";
		vRetResult.addElement(strTemp);//[2]sub_code
		vRetResult.addElement(rs.getString(4));//[3]sub_name
		vRetResult.addElement(rs.getString(5));//[4]is_force_closed
		vRetResult.addElement(String.valueOf(rs.getInt(6)));//[5]studEnrolled
		vRetResult.addElement(rs.getString(7));//[6]section
		vRetResult.addElement(rs.getString(8));//[7]is_requested_sub
		vRetResult.addElement(rs.getString(9));//[8]strCapacity
		
		iAvailSlot = rs.getInt(9) - rs.getInt(6);
		vRetResult.addElement(Integer.toString(iAvailSlot));//[9]strCapacity
		if(iAvailSlot <= 0)
			strTemp = "CLOSED";
		else
			strTemp = "OPEN";		
		if(rs.getInt(5) == 1)
			strTemp = "CLOSED";		
		vRetResult.addElement(strTemp);//[10]STATUS
	}rs.close();
	if(vRetResult.size() == 0) 
		strErrMsg = "No result found.";
	else{
		iElemCount = 11;
	
		Vector vTemp = new Vector();
		vTemp.addElement(strSYFrom);
		vTemp.addElement(strSemester);
		
		vSubSecInfo = SS.getScheduleMWFALL(dbOP, request, vTemp, true);
	}
}


if(vSubSecInfo == null)
	vSubSecInfo = new Vector();
	
String[] astrTermType = {"ALL TERM","1ST TERM","2ND TERM"};
String[] astrConvertSem = {"Summer", "1st Semester", "2nd Semester", "3rd Semester", "Fourth Semester"};
%>

<form name="form_" action="./class_program_persection_term_htc.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF"><strong>:::: 
          AVAILABLE SUBJECT REPORT PAGE ::::</strong></font></div></td>
    </tr>

    <tr> 
      <td width="3%">&nbsp;</td>
      <td colspan="4" height="25"><strong><font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4" valign="bottom">School year : 
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");

strSYFrom = strTemp;%> <input name="sy_from" type="text" class="textbox" id="sy_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' value="<%=strTemp%>" size="4" maxlength="4">
        to 

 <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");

strSYTo = strTemp;
%>
 <input name="sy_to" type="text" class="textbox" id="sy_to"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"
	  readonly="yes">
 &nbsp;&nbsp;&nbsp; &nbsp;Semester:
 <select name="semester">
 <%
 strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
 %>
	<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
      </select> </td>
    </tr>

	<tr>
      <td height="25">&nbsp;</td>
      <td width="13%">Term: </td>
	  <td width="84%" colspan="3">
	  <select name="term_type">
	  <option value=""></option>	  
	  <%
	  strTemp = WI.fillTextValue("term_type");
	  for(int i =0 ; i < astrTermType.length; ++i){
	  	if(strTemp.equals(Integer.toString(i)))
			strErrMsg = "selected";
		else
			strErrMsg = "";
	  %>
	  <option value="<%=i%>" <%=strErrMsg%>><%=astrTermType[i]%></option>
	 	<%}%>
	  </select>	  </td>
    </tr>
    
   
    
	
	
	
	
	<tr>
		<td colspan="2">&nbsp;</td>
		<td valign="bottom" colspan="3"><input type="image" src="../../../images/form_proceed.gif" border="0"></td>
	</tr>
	
    <tr><td colspan="5" height="20"></td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) { %>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myADTable2">
	<tr><Td align="right">
	<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
	<font size="1">Click to prnt report</font>
	</Td></tr>
</table>

<%
String strSchName = SchoolInformation.getSchoolName(dbOP, true, false);
String strSchAddr = SchoolInformation.getAddressLine1(dbOP, false, false);

int iMaxRowDisplay = 25;
int iRowDisplay = 0;

boolean bolPageBreak = false;

int iIndex = 0;
boolean bolTBA = false;
int iCount = 1;
String strDays = null;
String strTime = null;
String strRoom = null;
String strFaculty = null; Vector vTemp = null; String strIsLab = null;
int iLabelCount = 1;
for(int i =0; i < vRetResult.size(); ){

if(bolPageBreak){%>
	<div style="page-break-after:always">&nbsp;</div>
<%}%>





<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">	
	<tr><td height="22"><%=strSchName%></td></tr>
	<tr><td height="22"><%=strSchAddr%></td></tr>
	<tr><td height="25"></td></tr>
	<tr><td height="22"><strong>LIST OF AVAILABLE SUBJECTS</strong></td></tr>
	<tr><td height="22"><%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%></td></tr>
	<tr><td height="22"><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%></td></tr>
	<%
	if(WI.fillTextValue("term_type").length() > 0){
	%>
	<tr><td height="22"><%=astrTermType[Integer.parseInt(WI.fillTextValue("term_type"))]%></td></tr>
	<%}%>
	<tr><td height="25"></td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
<tr style="font-weight:bold">
    <td width="5%" class="thinborder">No.</td>
		<td width="15%" height="25" class="thinborder"><strong>Subject Code</strong></td>			
		<td class="thinborder"><strong>Description</strong></td>
		<td width="15%" class="thinborder" align="center">Schedule</td>
		<td width="8%" class="thinborder" align="center">Days</td>
		<td width="10%" class="thinborder" align="center">Room</td>
		
		<td width="5%" class="thinborder" align="center">Slot</td>
		<td width="5%" class="thinborder" align="center">Enrolled</td>
		<td width="5%" class="thinborder" align="center">Slot<br>Available</td>
		<td width="7%" class="thinborder" align="center">Sked.<br>Type</td>
		<td width="7%" class="thinborder" align="center"><strong>Status</strong></td>
	</tr>
	
	
	<%
	
	for(; i < vRetResult.size(); i+=iElemCount, iCount++){
		if(++iRowDisplay > iMaxRowDisplay){
			bolPageBreak = true;
			iRowDisplay = 0;
			break;
		}
	
		iIndexOf = vSubSecInfo.indexOf(vRetResult.elementAt(i));
		strDays = null;
		strTime = null;
		strRoom = null;
		strFaculty = null;

		if(iIndexOf > -1) {
			vTemp = (Vector)vSubSecInfo.elementAt(iIndexOf + 2);
			if(vSubSecInfo.elementAt(iIndexOf + 1).equals("1"))
				strIsLab = " (LAB)";
			else	
				strIsLab = "";
							
			while(vTemp.size() > 0) {					
				strTemp = (String)vTemp.remove(0);
				
				if(strRoom == null)
					strRoom = (String)vTemp.remove(0);
				else
					strRoom += "<br>"+(String)vTemp.remove(0);
				
				vTemp = CommonUtil.convertCSVToVector(strTemp, "<br>",true);
				
				while(vTemp.size() > 0){
					strTemp = (String)vTemp.remove(0);
					iIndex = strTemp.indexOf(" ");
					if(iIndex > -1){
						bolTBA = false;
						if(strTime == null){
							strTime = strTemp.substring(iIndex + 1).toLowerCase()+strIsLab;							
							bolTBA = strTime.trim().equalsIgnoreCase("0:00am-0:00am");
						}else{
							strTime += "<br>"+strTemp.substring(iIndex + 1).toLowerCase()+strIsLab;			
							bolTBA = strTemp.substring(iIndex + 1).trim().equalsIgnoreCase("0:00am-0:00am");		
						}
						
						if(strDays == null){
							if(bolTBA)
								strDays = "BY ARR";
							else
								strDays = strTemp.substring(0, iIndex);
						}else{
							if(bolTBA)
								strDays += "<br>BY ARR";
							else
								strDays += "<br>"+strTemp.substring(0, iIndex);
						}	
					}
				}
				
				
				
				strIsLab = "";
			}
			vTemp = (Vector)vSubSecInfo.elementAt(iIndexOf + 3);
			while(vTemp.size() > 0) {
				if(strFaculty != null)
					strFaculty = strFaculty + "<br>";
				
				strFaculty = WI.getStrValue(strFaculty) + (String)vTemp.remove(0);
			}
			
			vSubSecInfo.remove(iIndexOf);vSubSecInfo.remove(iIndexOf);vSubSecInfo.remove(iIndexOf);vSubSecInfo.remove(iIndexOf);
		}
	
	%>
	<tr>
		<td class="thinborder" align="right"><%=iCount%>.&nbsp;</td>
		<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
		<td class="thinborder" align="center"><%=WI.getStrValue(strTime, "&nbsp;")%></td>
		<td class="thinborder" align="center"><%=WI.getStrValue(strDays, "&nbsp;")%></td>
		<td class="thinborder" align="center"><%=WI.getStrValue(strRoom, "&nbsp;")%></td>
		<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+8), "&nbsp;")%></td>
		<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+5), "&nbsp;")%></td>
		<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+9), "&nbsp;")%></td>
		<td class="thinborder" align="center"><%=astrRequestedSub[Integer.parseInt((String)vRetResult.elementAt(i+7))]%></td>
		<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+10), "&nbsp;")%></td>
	</tr>
	<%}%>
</table>



<%}//end outer loop

} // if (vRetResult != null && vRetResult.size() > 0)%>


<input type="hidden" name="force_close_open" >
<input type="hidden" name="search_" >

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
