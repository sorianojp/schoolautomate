<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function AddRecord()
{
	document.eresult.addRecord.value =1;
}
function ReloadPage()
{
	document.eresult.addRecord.value =0;
	document.eresult.reloadPage.value =1;
	
	document.eresult.submit();
	
}
</script>
<body bgcolor="#D2ae72">
<%@ page language="java" import="utility.*,java.util.Vector,OLExam.OLECommonUtil,OLExam.OLEResult"%>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strSubName = null;
	Vector vSubList = new Vector();
	Vector vTemp = new Vector();

	
//add security here.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}


//end of security code. 
OLECommonUtil comUtil = new OLECommonUtil();
OLEResult oleResult   = new OLEResult();

vSubList = comUtil.getSubjectList(dbOP,request.getParameter("college"));
if(vSubList == null)
{
	if(strErrMsg != null)
		strErrMsg += comUtil.getErrMsg();
	else
		strErrMsg = comUtil.getErrMsg();
}
%>
<form name="eresult" method="post" action="./exam_result_view.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td width="88%" height="25" colspan="8"><div align="center"><strong> <font color="#FFFFFF" > 
          </font><font color="#FFFFFF" size="2" >:::: EXAM RESULTS PAGE ::::</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <%
if(strErrMsg == null) strErrMsg = "";
%>
      <td colspan="4"> <font size="3" face="Verdana, Arial, Helvetica, sans-serif"><strong><%=strErrMsg%></strong></font></td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td colspan="3">College of 
        <select name="college" onChange="ReloadPage();">
          <option value="0"> Select a College offering subject</option>
          <%=dbOP.loadCombo("C_INDEX","C_NAME"," from COLLEGE where IS_DEL=0 order by C_NAME asc", request.getParameter("college"), false)%> 
        </select> &nbsp;&nbsp;&nbsp;
        <input name="image" type="image" src="../../../images/form_proceed.gif" width="81" height="21"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="35%" valign="bottom" >Subject</td>
      <td width="20%">Offering year/term</td>
      <td width="42%"><input type="text" name="sy_from" maxlength="4" size="4" value="<%=WI.fillTextValue("sy_from")%>">
        to 
        <input type="text" name="sy_to" maxlength="4" size="4" value="<%=WI.fillTextValue("sy_to")%>"> &nbsp;&nbsp;
        <select name="semester">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("semester");
if(strTemp == null) strTemp = "";

if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3" ><select name="subject" onChange="ReloadPage();">
          <option value="0">Select a subject</option>
          <%
strTemp =WI.fillTextValue("subject");

if(vSubList != null)
{
	for(int i = 0; i< vSubList.size(); ++i)
	{
		if(strTemp.compareTo((String)vSubList.elementAt(i)) ==0)
		{%>
          <option value="<%=(String)vSubList.elementAt(i++)%>" selected><%=(String)vSubList.elementAt(i)%></option>
          <%}else{%>
          <option value="<%=(String)vSubList.elementAt(i++)%>"><%=(String)vSubList.elementAt(i)%></option>
          <%}
	}
} %>
        </select> 
        <%
//get the subject name here. 
strSubName = dbOP.mapOneToOther("subject","sub_index",request.getParameter("subject"),"sub_name",null);
if(strSubName == null)
	strSubName = "";
%>
        Subject Title : <strong><%=strSubName%></strong> </td>
    </tr>
    <%
if (vSubList != null && (request.getParameter("subject") != null || request.getParameter("subject").compareTo("0") != 0))
{
 vTemp = comUtil.getSectionOfferedByTheSubject(dbOP, request.getParameter("subject"), request.getParameter("sy_from"),
												request.getParameter("sy_to"),request.getParameter("semester"));
 if(vTemp == null || vTemp.size() ==0)
 {%>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3"><%=comUtil.getErrMsg()%></td>
    </tr>
    <%}else{%>
    <tr> 
      <td>&nbsp;</td>
      <td valign="bottom" >Section</td>
      <td valign="bottom" >Examination Period </td>
      <td valign="bottom" >&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td > <select name="section" onChange="ReloadPage();">
          <option value="0">Select a section</option>
          <%
strTemp =WI.fillTextValue("section");
for(int i = 0; i< vTemp.size(); ++i)
{
	if(strTemp.compareTo((String)vTemp.elementAt(i)) ==0)
	{%>
          <option value="<%=(String)vTemp.elementAt(i++)%>" selected><%=(String)vTemp.elementAt(i)%></option>
          <%}else{%>
          <option value="<%=(String)vTemp.elementAt(i++)%>"><%=(String)vTemp.elementAt(i)%></option>
          <%}
}
%>
        </select> </td>
      <td ><select name="exam_period" onChange="ReloadPage();">
          <%=dbOP.loadCombo("EPERIOD_INDEX","NAME"," from OLE_EPERIOD where IS_VALID=1 order by name asc", request.getParameter("exam_period"), false)%> 
        </select></td>
      <td ><input name="image2" type="image" src="../../../images/form_proceed.gif" width="81" height="21"></td>
    </tr>
    <tr> 
      <td colspan="4"><hr></td>
    </tr>
    <%
if(request.getParameter("section") != null && request.getParameter("section").compareTo("0") != 0)
{
vTemp = oleResult.getExamDetail(dbOP,request.getParameter("section"),request.getParameter("exam_period"));
if(vTemp != null && vTemp.size() > 0)
{
%>
    <tr> 
      <td>&nbsp;</td>
      <td valign="bottom" >Date of Exam - Time</td>
      <td valign="bottom" >duration in mins</td>
      <td valign="bottom" > Room #</td>
    </tr>
    <%for(int i = 0; i< vTemp.size(); ++i){%>
    <tr> 
      <td height="21">&nbsp;</td>
      <td ><%=(String)vTemp.elementAt(i)%> - <%=(String)vTemp.elementAt(i+1)%></td>
      <td ><%=(String)vTemp.elementAt(i+3)%></td>
      <td ><%=(String)vTemp.elementAt(i+2)%></td>
    </tr>
    <% i = i+3; 
	}
}//if exam period exists.
%>
    <tr> 
      <td>&nbsp;</td>
      <td  colspan="2"></td>
      <td >&nbsp;</td>
    </tr>
    <%}//if section is selected%>
  </table>
<%
//get the number of students appeard for this exam.
vTemp = oleResult.getExamResultPerSection(dbOP,request.getParameter("section"),request.getParameter("sy_from"),
				request.getParameter("sy_to"),request.getParameter("semester"));
int iTotalStudent = 0; 
float fTotalPts = 0;
float fTotalPtsScored = 0; 
float fPts = 0; //this is for individual score
String strPts = null;
float fTempPts = 0; 
boolean bolCalTotal = true;//false after calculating total points once.

String strTemp1 = null;
String strTemp2 = null;
String strTemp3 = null;
String strTemp4 = null;
String strTemp5 = null;



if(vTemp != null && vTemp.size() > 0)
{%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center">EXAMINATION 
          RESULT SUMMARY<strong></strong></div></td>
    </tr>
    <tr> 
      <td width="71%" height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="29%" height="25" bgcolor="#FFFFFF"><a href="exam_result_print.htm" target="_blank"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
        to print this page</font></td>
    </tr>
  </table>
	
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="8%" height="21" rowspan="2"><div align="center"><font size="1">STUDENT 
          ID</font></div></td>
      <td width="25%" rowspan="2"><div align="center"><font size="1">STUDENT NAME</font></div></td>
      <td width="32%" rowspan="2"><div align="center"><font size="1">COURSE/MAJOR</font></div></td>
      <td width="6%" rowspan="2"><div align="center"><font size="1">YEAR</font></div></td>
      <td colspan="5"><div align="center"><font size="1">SCORE</font></div></td>
      <td width="3%" rowspan="2"><div align="center"><font size="1">TOTAL SCORE</font></div></td>
      <td width="12%" rowspan="2"><div align="center"><font size="1">PERCENT-AGE 
          (%) </font></div></td>
    </tr>
    <tr> 
      <td width="3%"><div align="center">I</div></td>
      <td width="2%"><div align="center">II</div></td>
      <td width="3%"><div align="center">III</div></td>
      <td width="3%"><div align="center">IV</div></td>
      <td width="3%"><div align="center">V</div></td>
    </tr>
<%for(int i = 0 ; i< vTemp.size();){
strTemp1=null;strTemp2=null;strTemp3=null;strTemp4=null;strTemp5=null;
strTemp = (String)vTemp.elementAt(i);
%>
    <tr> 
      <td height="25"><font size="1"><%=(String)vTemp.elementAt(i+1)%></font></td>
      <td><font size="1"><%=(String)vTemp.elementAt(i+2)%></font></td>
      <td><font size="1"><%=(String)vTemp.elementAt(i+3)%>/ <%=WI.getStrValue(vTemp.elementAt(i+4))%></font></td>
      <td><font size="1"><%=(String)vTemp.elementAt(i+5)%></font></td>
      
	  <%for(int j=i; j< vTemp.size(); ){
	  if( ((String)vTemp.elementAt(j)).compareTo(strTemp) != 0) break;
	  if(bolCalTotal) //right now - it is considered the total points for exam is same - later if needed, calculate total pts of exam for each student.
	  	fTotalPts += Float.parseFloat((String)vTemp.elementAt(j+7));

  	  fTotalPtsScored += Float.parseFloat((String)vTemp.elementAt(j+8));	

	  //get exam I / II/III/IV/V
	  if( ((String)vTemp.elementAt(j+6)).compareTo("1") ==0 )
	  {
	  	if(Float.parseFloat((String)vTemp.elementAt(j+7)) >= 1)//show only if there is a question available.
	  		strTemp1 = (String)vTemp.elementAt(j+8);
		else
			strTemp1 = "&nbsp;";
	    j=j+9;i=j;continue;
	  }
	  else if( ((String)vTemp.elementAt(j+6)).compareTo("2") ==0 )
	  {
	  	if(Float.parseFloat((String)vTemp.elementAt(j+7)) >= 1)//show only if there is a question available.
	  		strTemp2 = (String)vTemp.elementAt(j+8);
		else
			strTemp2 = "&nbsp;";
	    j=j+9;i=j;continue;
	  }
	  else if( ((String)vTemp.elementAt(j+6)).compareTo("3") ==0 )
	  {
	  	if(Float.parseFloat((String)vTemp.elementAt(j+7)) >= 1)//show only if there is a question available.
	  		strTemp3 = (String)vTemp.elementAt(j+8);
		else
			strTemp3 = "&nbsp;";
	    j=j+9;i=j;continue;
	  }else if( ((String)vTemp.elementAt(j+6)).compareTo("4") ==0 )
	  {
	  	if(Float.parseFloat((String)vTemp.elementAt(j+7)) >= 1)//show only if there is a question available.
	  		strTemp4 = (String)vTemp.elementAt(j+8);
		else
			strTemp4 = "&nbsp;";
	    j=j+9;i=j;continue;
	  }else if( ((String)vTemp.elementAt(j+6)).compareTo("5") ==0 )
	  {
	  	if(Float.parseFloat((String)vTemp.elementAt(j+7)) >= 1)//show only if there is a question available.
	  		strTemp5 = (String)vTemp.elementAt(j+8);
		else
			strTemp5 = "&nbsp;";
	    j=j+9;i=j;continue;
	  }
	  j = j+9;
	  i=j;
	 }
	 if(strTemp1 == null) strTemp1 = "&nbsp;"; if(strTemp2 == null) strTemp2 = "&nbsp;";
     if(strTemp3 == null) strTemp3 = "&nbsp;"; if(strTemp4 == null) strTemp4 = "&nbsp;"; if(strTemp5 == null) strTemp5 = "&nbsp;";
//System.out.println((String)vTemp.elementAt(j+7));
//System.out.println((String)vTemp.elementAt(j+8));

	  %>
	  <td><font size="1"><%=strTemp1%></font></td>
      <td><font size="1"><%=strTemp2%></font></td>
      <td><font size="1"><%=strTemp3%></font></td>
      <td><font size="1"><%=strTemp4%></font></td>
      <td><font size="1"><%=strTemp5%></font></td>
	  
      <td><font size="1"><%=fTotalPtsScored%></font></td>
      <td><font size="1"><%=CommonUtil.calculatePercentage(fTotalPts,fTotalPtsScored)%></font></td>
    </tr>
<%bolCalTotal = false;
fTotalPtsScored = 0;
++iTotalStudent;
}%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="71%" height="25">TOTAL POINTS FOR THIS EXAM 
        : <strong><%=fTotalPts%></strong><br>
		TOTAL STUDENTS TAKING THIS EXAM : <strong><%=iTotalStudent%></strong></td>
      <td width="29%"><a href="exam_result_print.htm" target="_blank"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
        to print this page</font></td>
    </tr>
  </table>
<%} // only if there are students for exam.
else{%>
<table bgcolor="#FFFFFF" width="100%">
    <tr> 
      <td width="100%" colspan="3"><%=oleResult.getErrMsg()%></td>
    </tr>
  </table>
 <%}%>

  <table bgcolor="#FFFFFF" width="100%">
    <tr> 
      <td width="100%" colspan="3">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#B5AB73">
  <tr>
    <td>&nbsp;</td>
  </tr>
<%
	} //if subject is having a section. 
}//if subject is slected.%>
</table>
<!-- all hidden fields go here -->
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="exam_period_name" value="0">
<input type="hidden" name="section_name" value="0">

 </form>
</body>
</html>
<%
dbOP.cleanUP();
%>