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
		
	if(WI.fillTextValue("print_page").compareTo("1") == 0){%>
		<jsp:forward page="applicant_master_list_print_cit.jsp"/>
	<%return;}
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-ENTRANCE EXAM/INTERVIEW","applicant_master_list_cit.jsp");
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
														"applicant_master_list_cit.jsp");
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
	
	vExamList = appMgmt.operateOnMasterList(dbOP,request,1);
//	vExamList = appMgmt.operateOnMasterList(dbOP,request);
	if(vExamList == null)
		strErrMsg = appMgmt.getErrMsg();
	
	if(WI.fillTextValue("view_list").equals("1")){
		vMasterList = appMgmt.operateOnMasterList(dbOP,request,2);
//		vMasterList = appMgmt.operateOnMasterList(dbOP,request);
		if(vMasterList == null)
			strErrMsg = appMgmt.getErrMsg();
		else
			iSearch = appMgmt.getSearchCount();				
	}
%>
<form name="form_" action="./applicant_master_list_cit.jsp" method="post">
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
      <td colspan="3">&nbsp;&nbsp;<a href="javascript:ViewList();"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a>
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  
		View &nbsp;&nbsp;
		<%
		strTemp = WI.fillTextValue("view_new");
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<input type="checkbox" name="view_new" value="1" <%=strErrMsg%> >New Student
		<%		
		strTemp = WI.fillTextValue("view_old");
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<input type="checkbox" name="view_old" value="1" <%=strErrMsg%> >Old Student
		
      &nbsp; &nbsp; &nbsp; &nbsp;
      <%
		strTemp = WI.fillTextValue("show_college");
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
      <input type="checkbox"  name="show_college" value="1" <%=strErrMsg%>> Show College
      
      
	  </td>
    </tr>
    <tr> 
      <td height="18" width="2%">&nbsp;</td>
      <td colspan="3"></td>
    </tr>
  </table>
  <% if (vMasterList != null){%>
  <table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="39%" style="padding-left:100px;">
			<font color="#0099FF"><strong>&bull; NEW STUDENT</strong></font><br>
			<font color="#999999"><strong>&bull; OLD STUDENT</strong></font>
	  </td> 
      <td width="61%" colspan="9"> <div align="right">Number of Students Per Page 
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
  <%
  if(WI.fillTextValue("show_college").length() > 0)
	  	iAddColSpan = iAddColSpan + 2;
	else
		iAddColSpan = iAddColSpan + 1;
  %>
<input type="hidden" name="colSpan" value="<%=iAddColSpan%>"> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	  <tr bgcolor="#B9B292">
    	  <td height="23"><div align="center"><strong><font color="#FFFFFF" size="1">LIST OF APPLICANTS</font></strong></div></td>
      </tr>
  </table>			
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr> 
      <td height="23" align="right"> 
          <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
            <tr align="center" style="font-weight:bold"> 
              <td width="5%" rowspan="2" class="thinborder"><font size="1">Count</font></td>
              <td width="10%" rowspan="2" class="thinborder"><font size="1">ID Number </font></td>
              <td width="15%" rowspan="2" class="thinborder"><font size="1">Student Name </font></td>
              <td width="5%" rowspan="2" class="thinborder"><font size="1">Gender</font></td>
              <td width="15%" rowspan="2" class="thinborder"><font size="1">School Name </font></td>
              <td width="20%" rowspan="2" class="thinborder"><font size="1">School Address</font></td>
              <%if(WI.fillTextValue("show_college").length() > 0){%><td width="7%" rowspan="2" class="thinborder"><font size="1">College</font></td><%}%>
              <td width="7%" rowspan="2" class="thinborder"><font size="1">Course</font></td>
              <td width="8%" rowspan="2" class="thinborder"><font size="1">Date Taken</font></td>
              <%
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
              <td height="25" align="center" class="thinborder" width="5%"><strong><font size="1">Score</font></strong></td>
              <td align="center" class="thinborder" width="5%"><strong><font size="1">Classi- fication</font></strong></td>
              <%}}}%>
            </tr>
            <%
			
			
			/*for(int i = 0; i < vMasterList.size(); i += 14){
				if(!((String)vMasterList.elementAt(i)).equals("12-4092-648"))
					continue;
			
				System.out.println("PRINT "+i+":"+vMasterList.elementAt(i));
				System.out.println("PRINT "+(i+1)+":"+vMasterList.elementAt(i+1));
				System.out.println("PRINT "+(i+2)+":"+vMasterList.elementAt(i+2));
				System.out.println("PRINT "+(i+3)+":"+vMasterList.elementAt(i+3));
				System.out.println("PRINT "+(i+4)+":"+vMasterList.elementAt(i+4));
				System.out.println("PRINT "+(i+5)+":"+vMasterList.elementAt(i+5));
				System.out.println("PRINT "+(i+6)+":"+vMasterList.elementAt(i+6));
				System.out.println("PRINT "+(i+7)+":"+vMasterList.elementAt(i+7));
				System.out.println("PRINT "+(i+8)+":"+vMasterList.elementAt(i+8));
				System.out.println("PRINT "+(i+9)+":"+vMasterList.elementAt(i+9));
				System.out.println("PRINT "+(i+10)+":"+vMasterList.elementAt(i+10));
				System.out.println("PRINT "+(i+11)+":"+vMasterList.elementAt(i+11));
				System.out.println("PRINT "+(i+12)+":"+vMasterList.elementAt(i+12));
				System.out.println("PRINT "+(i+13)+":"+vMasterList.elementAt(i+13));
				
			}*/
			
			
			iAddColSpan = 1;//System.out.println(vMasterList);
			int v = 0;
			int u = 0;
			String strBGColor = " bgcolor='#FFFFFF'";
            for(; u < vMasterList.size(); u+=15,iAddColSpan++){
			if( (String)vMasterList.elementAt(u+13) != null && ((String)vMasterList.elementAt(u+13)).equals("1"))//temp stud
				strBGColor = " bgcolor='#0099FF'";
			else
				strBGColor = " bgcolor='#999999'";
			%>
            <tr <%=strBGColor%>> 
              <td class="thinborder"  height="25">&nbsp;<%=iAddColSpan%></td>
              <td class="thinborder"><%=(String)vMasterList.elementAt(u)%></td>
              <td class="thinborder">
                <%=WI.formatName((String)vMasterList.elementAt(u+1),(String)vMasterList.elementAt(u+2),(String)vMasterList.elementAt(u+3),4)%> </td>
              <td class="thinborder"><div align="center"><%=(String)vMasterList.elementAt(u+4)%></div></td>
			  <td class="thinborder"><%=WI.getStrValue((String)vMasterList.elementAt(u+11),"&nbsp;")%></td>            
              <td class="thinborder"><%=WI.getStrValue((String)vMasterList.elementAt(u+8),"&nbsp;")%></td>
              <%if(WI.fillTextValue("show_college").length() > 0){%><td class="thinborder"><%=WI.getStrValue((String)vMasterList.elementAt(u+14),"&nbsp;")%></td><%}%>
              <td class="thinborder"><%=WI.getStrValue((String)vMasterList.elementAt(u+10),"na")%></td>
              <td class="thinborder"><%=(String)vMasterList.elementAt(u+5)%>
              	    
                <%				
				for(v = u; (v + 15) < vMasterList.size() ;){
				 if(((String)vMasterList.elementAt(v)).compareTo((String)vMasterList.elementAt(v + 15)) != 0)
						break;
			 	%>
                 <br>
                	<%=(String)vMasterList.elementAt(v + 15 + 5)%>
                 <%				 	
					v += 15;
				}%>		
              </td>		  
			  
			  <%
			  if(vExamList != null){
			  int iCount = 0;
			  for(int iLoop = 0;iLoop < vExamList.size();iLoop += 2){
					if(WI.fillTextValue("subject_"+(iLoop+2)/2).length() > 0){
				    	iCount++;					
					    if(u < vMasterList.size()){
					  		if(((String)vExamIndex.elementAt(iCount-1)).equals((String)vMasterList.elementAt(u+6))){%>					
								  <td width="34" class="thinborder"><%=WI.getStrValue((String)vMasterList.elementAt(u+9),"&nbsp;")%></td>
								  <td width="47" class="thinborder"><%=WI.getStrValue((String)vMasterList.elementAt(u+7),"&nbsp;")%></td>
							<%
							if(u+15 < vMasterList.size()){
								if(((String)vMasterList.elementAt(u)).compareTo((String)vMasterList.elementAt(u + 15)) == 0)//if same id
									u+=15;
							} 
						   }else{%>
						   		<td width="13" class="thinborder">&nbsp;</td>
						   		<td width="80" class="thinborder">&nbsp;</td>
						   <%}
			   			}
			  		}
			 	}
			}%>
            </tr>
            <%}%>
            <tr>            </tr>
          </table>
   	<tr>		  
       <td>&nbsp;</td>
    </tr>
  </table>
	
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