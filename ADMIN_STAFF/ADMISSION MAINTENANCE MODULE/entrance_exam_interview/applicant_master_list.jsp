<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 11px}
-->
</style>
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
function ViewList(){
	document.form_.view_list.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');	
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	Vector vExamIndex = new Vector();	
	Vector vMasterList = null;
	Vector vExamList = null;
	String strErrMsg  = null;
	String strTemp    = null;	
	int iSearch = 0;
	int iAddColSpan = 7;	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";	
		
	boolean bolIsAUF = strSchCode.startsWith("AUF");//there are few changes in the form for AUF.. 
	
	if(WI.fillTextValue("print_page").compareTo("1") == 0){%>
		<jsp:forward page="applicant_master_list_print.jsp"/>
	<%return;}
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-ENTRANCE EXAM/INTERVIEW","exam_sched.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission Maintenance","ENTRANCE EXAM/INTERVIEW",request.getRemoteAddr(),
														"exam_sched.jsp");
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
}//end of authenticaion code.
	
	ApplicationMgmt appMgmt = new ApplicationMgmt();
	
	//if(!strSchCode.startsWith("CGH")) {
		vExamList = appMgmt.operateOnMasterList(dbOP,request,1);
		if(vExamList == null)
			strErrMsg = appMgmt.getErrMsg();
	//}
	//else	
	//	vExamList = new Vector();
	
	if(WI.fillTextValue("view_list").equals("1")){
		vMasterList = appMgmt.operateOnMasterList(dbOP,request,2);
//		vMasterList = appMgmt.operateOnMasterList(dbOP,request);
		if(vMasterList == null)
			strErrMsg = appMgmt.getErrMsg();
		else
			iSearch = appMgmt.getSearchCount();				
	}
%>
<form name="form_" action="./applicant_master_list.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><strong><font color="#FFFFFF">:::: 
          APPLICANT MASTER LIST PAGE::::</font></strong></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%> </strong></font></td>
    </tr>
    <tr> 
      <td height="35">&nbsp;</td>
      <td width="18%">School Year / Term:</td>
      <td width="80%" colspan="2"> <% strTemp = WI.fillTextValue("sy_from");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); 
		%> <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
		onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
		onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%  strTemp = WI.fillTextValue("sy_to");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); 
		%> <input name="sy_to" type="text" size="4" maxlength="4" 
		value="<%=strTemp%>" class="textbox"
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        / 
        <select name="semester">
          <% strTemp = WI.fillTextValue("semester");
		if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
		if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected=>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  if (!strSchCode.startsWith("CPU")) { 
		  
		  if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  }
		  %>
        </select> </td>
    </tr>
    <tr>
		<td height="25">&nbsp;</td>
		<td>College</td>
		<td><select name="c_index" onChange="document.form_.submit();">
          <option value="">All</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select></td>
	</tr>
   <tr>
		<td height="25">&nbsp;</td>
		<td>Course</td>
		<td>
		<%
		if(WI.fillTextValue("c_index").length() > 0)
		{
			strTemp = " from course_offered where IS_DEL=0 and is_valid=1 and is_offered = 1 and c_index="+WI.fillTextValue("c_index")+
					" order by course_name asc" ;
		}
		else
			strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and is_offered = 1 order by course_name asc";
		%>
			<select name="course_index">
         	<option value="">All</option>
				<%=dbOP.loadCombo("course_index","course_code, course_name", strTemp, WI.fillTextValue("course_index"),false)%>
			</select>
		</td>
	</tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">Master List For:</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"> 
	   <%if(vExamList != null){
	  		for(int iLoop = 0;iLoop < vExamList.size();iLoop += 2){
				if(WI.fillTextValue("subject_"+(iLoop+2)/2).length() > 0){
					strTemp = "checked";
					iAddColSpan += 2;
				}					
				else
					strTemp = "";
				%>							
			<input name="subject_<%=(iLoop+2)/2%>" type="checkbox" value="<%=(String)vExamList.elementAt(iLoop)%>" <%=strTemp%>> 
            <%=(String)vExamList.elementAt(iLoop+1)%>&nbsp; 
		
		<%}%><input type="hidden" name="numOfExams" value="<%=(vExamList.size()/2)%>">
		<%}%> </td>
    </tr>
    <tr> 
      <td height="35">&nbsp;</td>
      <td>Date of Exam:</td>
      <td colspan="2"> From: 
        <input name="exam_date_fr" type="text" class="textbox" size="10" maxlength="10" value="<%=WI.fillTextValue("exam_date_fr" )%>" readonly> 
        <a href="javascript:show_calendar('form_.exam_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        To: 
        <input name="exam_date_to" type="text" class="textbox" size="10" maxlength="10" value="<%=WI.fillTextValue("exam_date_to")%>" readonly> 
        <a href="javascript:show_calendar('form_.exam_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;&nbsp;<a href="javascript:ViewList();"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
      
      <%
		strTemp = WI.fillTextValue("show_college");
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
      <td><input type="checkbox"  name="show_college" value="1" <%=strErrMsg%>> Show College</td>
    </tr>
    <tr> 
      <td height="18" width="2%">&nbsp;</td>
      <td colspan="3"></td>
    </tr>
  </table>
  <% if (vMasterList != null){
  	if(strSchCode.startsWith("CGH"))
		vExamList = new Vector();

  %>
  <table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
    <tr>       
      <td width="69%" colspan="9"> <div align="right">Number of Students Per Page 
          : 
          <select name="num_stud_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_stud_page"),"20"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          &nbsp;&nbsp;&nbsp; <a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
          to print</font></div></td>        
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr> 
      <td height="23" align="right"> 
          <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
            <tr bgcolor="#B9B292">
			<%if(bolIsAUF)
				iAddColSpan = 7;
			%>	
			<input type="hidden" name="colSpan" value="<%=iAddColSpan%>"> 
              <td height="23" colspan="<%=vExamList.size() + 8%>"><div align="center"><strong><font color="#FFFFFF" size="1">LIST 
                  OF APPLICANTS</font></strong></div></td>
            </tr>
            <tr> 
              <td width="67" rowspan="2" align="center" class="thinborder"><strong><font size="1">NO.</font></strong></td>
              <td width="67" rowspan="2" align="center" class="thinborder"><strong><font size="1">ID</font></strong></td>
              <td width="383" rowspan="2" align="center" class="thinborder"><strong><font size="1">NAME</font></strong></td>
              <td width="58" rowspan="2" align="center" class="thinborder"><strong><font size="1">SEX</font></strong></td>
              <td width="76" rowspan="2" align="center" class="thinborder"><strong><font size="1">PREV SCHOOL</font></strong></td>
              <%if(WI.fillTextValue("show_college").length() > 0){%>
              	<td width="67" rowspan="2" align="center" class="thinborder"><strong><font size="1">COLLEGE</font></strong></td>
              <%}%>
              <td width="67" rowspan="2" align="center" class="thinborder"><strong><font size="1">COURSE</font></strong></td>
              <td width="67" rowspan="2" align="center" class="thinborder"><strong><font size="1">
			  	<%if(bolIsAUF){%>
					DATE OF EXAM
				<%}else{%>
					DATE TAKEN 
				<%}%>
			  </font></strong></td>
              <%if(bolIsAUF)
					vExamList = null;

			  if(vExamList != null){
			  for(int iLoop = 0;iLoop < vExamList.size();iLoop += 2){
				if(WI.fillTextValue("subject_"+(iLoop+2)/2).length() > 0){
				    vExamIndex.addElement((String)vExamList.elementAt(iLoop));%>			  
              		<td height="25" colspan="2" align="center" class="thinborder"> 
              		  <strong><font size="1"><%=(String)vExamList.elementAt(iLoop+1)%></font></strong></td>
              		<%} // if(WI.fillTextValue("subject_"+(iLoop+2)/2).length()
			   } //  for loop
			  }%>
			</tr>
            <tr>
			<%
			  if(vExamList != null){
			  for(int iLoop = 0;iLoop < vExamList.size();iLoop += 2){
				if(WI.fillTextValue("subject_"+(iLoop+2)/2).length() > 0){%>
              <td height="25" align="center" class="thinborder"><strong><font size="1">SCORE</font></strong></td>
              <td align="center" class="thinborder"><strong><font size="1">SUBJECT 
                TO TAKE</font></strong></td>
              <%}}}%>
            </tr>
            <%
			iAddColSpan = 1;
			int v = 0;
			int u = 0;
			if(strSchCode.startsWith("UI")) 
				u = 3;
			
            for(; u < vMasterList.size(); u += 13,iAddColSpan++){%>
            <tr> 
              <td class="thinborder"  height="25">&nbsp;<%=iAddColSpan%></td>
              <td align="center" class="thinborder"><%=(String)vMasterList.elementAt(u)%></td>
              <td class="thinborder">&nbsp;
                <%=WI.formatName((String)vMasterList.elementAt(u+1),(String)vMasterList.elementAt(u+2),(String)vMasterList.elementAt(u+3),4)%> </td>
              <td class="thinborder"><div align="center"><%=(String)vMasterList.elementAt(u+4)%></div></td>
			  <td class="thinborder"><%=WI.getStrValue((String)vMasterList.elementAt(u+11),"&nbsp;")%></td>
			  <%if(WI.fillTextValue("show_college").length() > 0){%><td class="thinborder"><%=WI.getStrValue((String)vMasterList.elementAt(u+12),"&nbsp;")%></td><%}%>
              <td class="thinborder"><%=WI.getStrValue((String)vMasterList.elementAt(u+10),"na")%></td>
              <td class="thinborder"><div align="center"><%=(String)vMasterList.elementAt(u+5)%>
                
                <%
				for(v = u; (v + 13) < vMasterList.size() ;){
				 if(((String)vMasterList.elementAt(v)).compareTo((String)vMasterList.elementAt(v + 13)) != 0)
						break;%>
                 <br>
                <%=(String)vMasterList.elementAt(v + 13 + 5)%>
                 <%v += 13;}%>			  
              </div></td>		  
			  
			  <%
			  if(vExamList != null){
			  int iCount = 0;
			  for(int iLoop = 0;iLoop < vExamList.size();iLoop += 2){
				if(WI.fillTextValue("subject_"+(iLoop+2)/2).length() > 0){
				    iCount++;					
			   if(u < vMasterList.size()){
			  		if(((String)vExamIndex.elementAt(iCount-1)).equals((String)vMasterList.elementAt(u+6))){%>					
              <td width="34" class="thinborder"> <div align="center"><%=WI.getStrValue((String)vMasterList.elementAt(u+9),"0")%></div></td>
              <td width="47" class="thinborder">
			    
	            <div align="center">
	              <%if(Integer.parseInt(WI.getStrValue((String)vMasterList.elementAt(u+9),"0")) < Integer.parseInt((String)vMasterList.elementAt(u+8)))
			  		strTemp = "+";			  
			    else
			    	strTemp = "1";
			  %>
	              <%=strTemp%></div></td>
			  <%if(u+13 < vMasterList.size()){
			   		if(((String)vMasterList.elementAt(u)).compareTo((String)vMasterList.elementAt(u + 13)) == 0)
			   			u+=13;
			     } 
			   }else{%>
			   <td width="13" class="thinborder">&nbsp;
		         <div align="center"></div></td>
               <td width="80" class="thinborder">&nbsp;
                 <div align="center"></div></td
			   ><%}}}}}%>
            </tr>
            <%}%>
            <tr>            </tr>
          </table>
   	<tr>		  
       <td>&nbsp;</td>
    </tr>
  </table>
<% if (strSchCode.startsWith("UI") && vMasterList.size() > 3) {
	int iRowTotal = 0; 

	Vector vTemp = 	(Vector)vMasterList.elementAt(0);
    int k = 0;	
	
	%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">	
	<tr>
		<td>
<% 
	 if (vTemp != null && vTemp.size() > 0) {
		  vExamList = (Vector)vTemp.elementAt(0);
		  int[] iColTotal = new int[vExamList.size()*2];
		  
		  for (k = 0; k < vExamList.size()*2; k++)
		  	iColTotal[k] = 0;
	 %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
  <tr>
  	<td colspan="3" align="center">
		Detailed information of number of applicants who passed or failed in the Placement Test    </td>
  </tr>
  </table>	 
  <table width="85%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder" id="myADTable2">
   
  <tr>
  	<td width="20%" rowspan="2" align="center" class="thinborder"><strong>COURSE</strong></td>
	<% for (k = 0; k < vExamList.size(); k++){%> 
    <td colspan="2" align="center" class="thinborder"><%=(String)vExamList.elementAt(k)%></td>
	<%}%>
   </tr>
  <tr>
    <% for (k = 0; k < vExamList.size(); k++){%> 	
    <td width="10%" align="center" class="thinborder">Passed</td>
    <td width="10%" align="center" class="thinborder">Failed</td>
	<%}%> 
  </tr>
  <% String strCourse =null;
  	for (int i = 1; i < vTemp.size();) {
	
	  	strCourse = (String)vTemp.elementAt(i);
		
	
  %>
  <tr>
    <td align="center" class="thinborder"><%=strCourse%></td>
	<% for (k=0; k < vExamList.size(); k++){
	
		if (((String)vTemp.elementAt(i+2)).equals((String)vExamList.elementAt(k)) && 
			((String)vTemp.elementAt(i+3)).equals("0")){  // passs
			
			strTemp = (String)vTemp.elementAt(i+4);
			iColTotal[2*k] += Integer.parseInt(strTemp);

			i+=5;			
		}else{
			strTemp = "0";
		}
		
		%> 
	    <td align="center" class="thinborder">&nbsp;<%=strTemp%></td>
		<%
			if ( i < vTemp.size() &&
				strCourse.equals((String)vTemp.elementAt(i)) && 
				((String)vTemp.elementAt(i+2)).equals((String)vExamList.elementAt(k)) && 
				((String)vTemp.elementAt(i+3)).equals("1")){  // 1
				
				strTemp = (String)vTemp.elementAt(i+4);
				iColTotal[2*k+1] += Integer.parseInt(strTemp);				
				i+=5;			
			}else{
				strTemp = "0";
			}
		%>			
	    <td align="center" class="thinborder">&nbsp;<%=strTemp%></td>
	<%}%> 
  </tr>
  <%}%>
  <tr>
    <td align="center" class="thinborder"><strong>Subtotal</strong></td>
	<% for (k=0; k < vExamList.size(); k++){ %> 
	    <td align="center" class="thinborder">&nbsp;<%=iColTotal[2*k]%></td>
	    <td align="center" class="thinborder">&nbsp;<%=iColTotal[2*k+1]%></td>
	<%}%> 
  </tr>
  </table>  </td>
	</tr>
	<tr>
	  <td>&nbsp;</td>
    </tr>
	<tr>
	  <td align="center"><strong>::: SUMMARY :::</strong> </td>
    </tr>
	<tr>
	  <td align="center">&nbsp;</td>
    </tr>
	<tr>
	  <td align="center">
		<table width="60%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">

  	<% for (k = 0; k < vExamList.size(); k++){%>    
  <tr>

    <td width="40%" rowspan="2" align="center" class="thinborder">
				<%=(String)vExamList.elementAt(k)%>	</td>

    <td width="30%" align="center" class="thinborder">Passed</td>
    <td width="30%" align="center" class="thinborder"><%=iColTotal[2*k]%></td>
  </tr>
  <tr>
    <td align="center" class="thinborder">Failed</td>
    <td align="center" class="thinborder"><%=iColTotal[2*k+1]%></td>
  </tr>
   	<%}%>
	  </table>	  </td>
    </tr>
	<tr>
	  <td align="center">&nbsp;</td>
    </tr>
  <% strCourse =null;
  	vTemp =  (Vector)vMasterList.elementAt(1);
	
	iColTotal[0] = 0;
	iColTotal[1] = 0; 
	
	
	if (vTemp != null && vTemp.size() > 0) {
  %>	
	<tr>
	  <td align="center"><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
      <p class="style1">Summary  	of Male / Female Applicants</p></td>
    </tr>
	<tr>
	  <td align="center">
	  
	  <table width="85%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
        <tr>
          <td width="20%" rowspan="2" align="center" class="thinborder"><strong>Course</strong></td>
          <td colspan="2" align="center" class="thinborder">Gender</td>
          <td width="10%" rowspan="2" align="center" class="thinborder">Total</td>
        </tr>
        <tr>
          <td width="10%" align="center" class="thinborder">Male</td>
          <td width="10%" align="center" class="thinborder">Female</td>
        </tr>
<%
	
  	for (int i = 0; i < vTemp.size();i+=3) {
	  	strCourse = (String)vTemp.elementAt(i);
		iRowTotal = 0;
  %>
        <tr>
          <td align="center" class="thinborder"><%=strCourse%></td>
         <%
	
		if (((String)vTemp.elementAt(i+1)).equals("M"))
		{  // MALE, 
			
			strTemp = (String)vTemp.elementAt(i+2);
			iColTotal[0] += Integer.parseInt(strTemp);
			iRowTotal = Integer.parseInt(strTemp);
			i+=3;			
		}else{
			strTemp = "0";
		}
		
		%>
          <td align="center" class="thinborder">&nbsp;<%=strTemp%></td>
          <%
			if ( i < vTemp.size() &&
				strCourse.equals((String)vTemp.elementAt(i)) && 
				((String)vTemp.elementAt(i+1)).equals("F")){  // 1
				
				strTemp = (String)vTemp.elementAt(i+2);
				iRowTotal += Integer.parseInt(strTemp);
				iColTotal[1] += Integer.parseInt(strTemp);				
			}else{
				strTemp = "0";
			}
		%>
          <td align="center" class="thinborder">&nbsp;<%=strTemp%></td>
          <td align="center" class="thinborder">&nbsp;<%=iRowTotal%></td>
        </tr>
        <%}%>
        <tr>
          <td align="right" class="thinborder">TOTAL&nbsp;&nbsp;</td>
          <td align="center" class="thinborder"><%=iColTotal[0]%></td>
          <td align="center" class="thinborder"><%=iColTotal[1]%></td>
          <td align="center" class="thinborder"><%=iColTotal[0] + iColTotal[1]%></td>
        </tr>		
      </table></td>
    </tr>
	<%
	  } // if vtemp.size() > 0 ... summary of course applicant per gender.. 
	%> 
	<tr>
	  <td align="center">&nbsp;</td>
    </tr>
	
  <% strCourse =null;
  	vTemp =  (Vector)vMasterList.elementAt(2);
	
	  for (k = 0; k < vExamList.size()*2; k++)
		iColTotal[k] = 0;	
	
	
	%>
	
	<tr>
	  <td align="center"><p class="style1">Summary of number of male / female  applicants who passed / failed in the Placement Test</p></td>
    </tr>
	<tr>
	  <td align="center"><table width="85%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
        <tr>
          <td width="20%" rowspan="2" align="center" class="thinborder"><strong>Gender</strong></td>
			<% for (k = 0; k < vExamList.size(); k++){%> 
			    <td colspan="2" align="center" class="thinborder">
						<%=(String)vExamList.elementAt(k)%>
				</td>
		  <%}%>
          </tr>
        <tr>
	<% for (k = 0; k < vExamList.size(); k++){%> 
          <td width="10%" align="center" class="thinborder">Passed </td>
          <td width="10%" align="center" class="thinborder">Failed </td>
	  <%}%>
        </tr>
        <%
	
  	for (int i = 0; i < vTemp.size();i+=4) {
	  	strCourse = (String)vTemp.elementAt(i);
		
		if (strCourse.equals("M")) 
			strTemp = "Male";
		else
			strTemp = "Female";
		
		iRowTotal = 0;
  %>
        <tr>
          <td align="center" class="thinborder"><%=strTemp%></td>
	<% for (k=0; k < vExamList.size(); k++){
	
		if (((String)vTemp.elementAt(i+1)).equals((String)vExamList.elementAt(k)) && 
			((String)vTemp.elementAt(i+2)).equals("0")){  // passs
			
			strTemp = (String)vTemp.elementAt(i+3);
			iColTotal[2*k] += Integer.parseInt(strTemp);

			i+=4;			
		}else{
			strTemp = "0";
		}
		
		%> 
	    <td align="center" class="thinborder">&nbsp;<%=strTemp%></td>
		<%
			if ( i < vTemp.size() &&
				strCourse.equals((String)vTemp.elementAt(i)) && 
				((String)vTemp.elementAt(i+1)).equals((String)vExamList.elementAt(k)) && 
				((String)vTemp.elementAt(i+2)).equals("1")){  // 1
				
				strTemp = (String)vTemp.elementAt(i+3);
				iColTotal[2*k+1] += Integer.parseInt(strTemp);				
				i+=4;			
			}else{
				strTemp = "0";
			}
		%>			
	    <td align="center" class="thinborder">&nbsp;<%=strTemp%></td>
			<%}%> 
	
	      </tr>
        <%}%>
        <tr>
          <td align="right" class="thinborder">TOTAL&nbsp;&nbsp;</td>
	<% for (k=0; k < vExamList.size(); k++){ %> 
		    <td align="center" class="thinborder">&nbsp;<%=iColTotal[2*k]%></td>
		    <td align="center" class="thinborder">&nbsp;<%=iColTotal[2*k+1]%></td>
	<%}%> 
          </tr>
      </table></td>
    </tr>
	<tr>
	  <td align="center">&nbsp;</td>
    </tr>
  <% } // end vTemp != null  %>		
 </table>
  <%  } // specific for UI Reports only..  %>
	
<%  }%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="view_list" value="">
  <input type="hidden" name="print_page" value="">
  
  <!--this is added so that in the method only this jsp file will add element in the vector when calling the method.-->
  <input type="hidden" name="from_applicant_master_list" value="1">
  
</form>
</body>
</html>
<% dbOP.cleanUP();
%>