<%@ page language="java" import="utility.*,enrollment.GraduateReportSWU,java.util.Vector" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css" />
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
function AjaxMapName(strPos){
	var strCompleteNaem;
	strCompleteName = document.form_.stud_id.value;
	if(strCompleteName.length<2)
		return;
	
	var objCOAInput;
	objCOAInput = document.getElementById("coa_info");
	
	this.InitXmlHttpObject(objCOAInput,2);
	if(this.xmlHttp == null){
	   alert("Failed to init xmlHttp.");
	   return;	
	}
    
	var strURL ="../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strCompleteName);
    this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex){
    document.form_.stud_id.value= strID;
}
function UpdateNameFormat(strName){
	document.getElementById("coa_info").innerHTML="";
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintPg(strInfoIndex){
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value = "1";
	document.form_.submit();
}
function ReloadPage(){
	document.form_.view_fields.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.info_index.value = "";
	document.form_.print_page.value = "";
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.view_fields.value = "1";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value = "";
	document.form_.submit();
}
function DeleteRecord(strInfoIndex){
	if(!confirm("Are you sure you want to delete this record?"))
		return;
	document.form_.prepareToEdit.value="";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value = "";
	document.form_.page_action.value = "0";
	document.form_.submit();
}
function UpdateRecord(){
	document.form_.prepareToEdit.value="";
	document.form_.page_action.value = "1";
	document.form_.print_page.value="";
	document.form_.submit();
}
function EditRecord(strInfoIndex){		
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "2";
	document.form_.print_page.value="";
	document.form_.submit();
}
function RefreshPage(strViewFields){
	document.form_.view_fields.value = strViewFields;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.info_index.value = "";	
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%
    DBOperation dbOP= null;
	String strTemp = null;
	String strErrMsg = null;
	WebInterface WI = new WebInterface(request);
	String strImgFileExt = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./graduate_status_tracker_report_print.jsp" />
		<%return;
	}
	

  	try{
		dbOP = new DBOperation((String) request.getSession(false).getAttribute("userId"),
			"Admin/staff-Registrar Management-Graduates","graduate_status_tracker_report.jsp");
		ReadPropertyFile readProp = new ReadPropertyFile();
		strImgFileExt = readProp.getImageFileExtn("imgFileUploadExt");
		if(strImgFileExt==null || strImgFileExt.trim().length()==0){
		     strErrMsg ="Image file extension is missing.Please contact school admin.";
			 dbOP.cleanUP();
		}
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center">
			<font face="Verdana, Arial, Helvetica, sans-serif" size="3">
			 Error in opening connection
			</font>
		</p>	
<%	 return;
    }
  
     //authenticate this user.
     	CommonUtil comUtil = new CommonUtil();
     	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
     				"Registrar Management","REPORTS",request.getRemoteAddr(),"graduate_status_tracker_report.jsp");
     				
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
     		
     	Vector vRetResult = null;	
		Vector vRecords   = null;
		Vector vEditInfo  = null;
		
		GraduateReportSWU grad = new GraduateReportSWU();
		
		String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0"); 
		String strViewFields = WI.getStrValue(WI.fillTextValue("view_fields"),"0"); 
		
		strTemp = WI.fillTextValue("page_action");  
		if(strTemp.length()>0){
		   if(grad.operateGradStatTrackerReport(dbOP, request,Integer.parseInt(strTemp))==null)
		   		strErrMsg = grad.getErrMsg();
		   else{
		   		if(strTemp.equals("0"))
					strErrMsg= "Entry Successfully Deleted.";
		        if(strTemp.equals("1"))
		   			strErrMsg= "Entry Successfully Saved.";
				if(strTemp.equals("2"))
					strErrMsg= "Entry Successfully Updated.";
				strPrepareToEdit ="0";
				strViewFields ="0";
		   }		
		}	 
		  
		if(strPrepareToEdit.equals("1")){
			vEditInfo = grad.operateGradStatTrackerReport(dbOP, request, 3);
			if(vEditInfo == null)
				strErrMsg = grad.getErrMsg();	
		}
		  	
		if(WI.fillTextValue("stud_id").length() > 0){
			vRetResult = grad.operateGradStatTrackerReport(dbOP,request,6);
		    if(vRetResult == null)
		   		strErrMsg = grad.getErrMsg();		
			else{
				vRecords = grad.operateGradStatTrackerReport(dbOP, request, 5);	
				if(vRecords == null)
					strErrMsg = grad.getErrMsg();	
			}
	    }			  		
     %>
     <form name="form_" action="./graduate_status_tracker_report.jsp" method="post">
       <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
         <tr>
           <td height="25" colspan="5" bgcolor="#A49A6A">
     	  <div align="center"><font color="#FFFFFF"><strong>:::: GRADUATE STATUS TRACKER REPORT PAGE::::</strong></font></div>
     	  </td>
         </tr>
         <tr>
           <td width="3%" height="25" >&nbsp;</td>
           <td width="97%" height="25" colspan="4" ><font size="2"><strong><%=WI.getStrValue(strErrMsg,"")%></strong></font></td>
         </tr>
       </table>
       <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">         
     	<tr>
     	   <td width="4%" height="25">&nbsp;</td>
            <td width="8%" height="25"><strong>ID NUMBER </font></strong></td>
            <td height="25" colspan="2">
     	   <input name="stud_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
     	   onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("stud_id")%>" size="16"  onKeyUp="AjaxMapName('1');">
     	   &nbsp;&nbsp;
     	   <a href="javascript:OpenSearch();"%><img src="../../../images/search.gif" border="0"></a>   
     	   <label id="coa_info" style="font-size:11px; position:absolute; width:300px; font-weight:bold; color:#0000FF"></label>	      	   </td>
     	</tr>     	
     	<tr>
     		<td height="10" colspan="4">&nbsp;</td>
     	</tr>
         <tr>
           <td height="25" >&nbsp;</td>
           <td >&nbsp;</td>
           <td width="27%">
		   <a href="javascript:RefreshPage('')"%><img src="../../../images/form_proceed.gif" border="0"></a></td>
		   <td width="61%"><a href="javascript:RefreshPage('1');">Click to create new record.</a></td>
         </tr>
         <tr>
           <td height="30" colspan="4"><hr size="1"></td>
         </tr>
       </table> 
<%if(strViewFields.equals("1") || (vEditInfo !=null && vEditInfo.size()>0) || (vRetResult !=null && vRetResult.size()>0)){%>
       <table width="100%" border="0" cellspacing="0" cellpadding="2" bgcolor="#FFFFFF">  
          <tr>
		  	  <td width="32%" align="right" height="25" valign="bottom"><strong>Name</strong>
			  <td colspan="4" valign="bottom">
			  <div style="border-bottom: solid 1px #000000;">
			  <strong><%=(String)vRetResult.elementAt(0)%></strong>
			  </div></td>
			  <td width="3%">&nbsp;</td>
			  <td colspan="2" rowspan="7" valign="top">
			  <img src="../../../upload_img/<%=request.getParameter("stud_id")%>.<%=strImgFileExt%>" width="200" height="180"/>
			  </td>
		  </tr>    
		  <tr>
		  	  <td align="right" height="25" valign="bottom">Date of Birth</td>
		      <td colspan="4" valign="bottom">
			  <div style="border-bottom:solid 1px #000000;">
			  <strong><%=WI.getStrValue((String)vRetResult.elementAt(1))%></strong>
			  </div>
			  </td>
			  <td>&nbsp;</td>
			  
		  </tr>
		  <tr>
		  	  <td align="right" height="25" valign="bottom">Place of Birth</td>
			  <td colspan="4" valign="bottom">
			  <div style="border-bottom:solid 1px #000000;">
			  <strong><%=WI.getStrValue((String)vRetResult.elementAt(2))%></strong>
			  </div></td>
			  <td>&nbsp;</td>
		  </tr>    
		  <tr>
		  	  <td align="right" height="25" valign="bottom">Blood type</td>
			  <td colspan="4" valign="bottom"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
			  <td>&nbsp;</td>
		  </tr>
		  <tr>
		   	  <td align="right" height="25">Home Address</td>
			  <td colspan="4" valign="bottom"><div style="border-bottom:solid 1px #000000;">
			  <strong><%=WI.getStrValue((String)vRetResult.elementAt(3))%> 
			  <%=WI.getStrValue((String)vRetResult.elementAt(4),",","","")%>
			  <%=WI.getStrValue((String)vRetResult.elementAt(5),",","","")%>
			  <%=WI.getStrValue((String)vRetResult.elementAt(6),",","","")%>
			  </strong>
			  </div></td>
			  <td>&nbsp;</td>
		  </tr>
		  <tr>
		  	<td align="right" height="25" valign="bottom">Provincial/Permanent address</td>
			<td colspan="4" valign="bottom">
			<div style="border-bottom:solid 1px #000000;">
			<strong><%=WI.getStrValue((String)vRetResult.elementAt(3))%>
			<%=WI.getStrValue((String)vRetResult.elementAt(4),",","","")%>
			<%=WI.getStrValue((String)vRetResult.elementAt(5),",","","")%>
			<%=WI.getStrValue((String)vRetResult.elementAt(6),",","","")%>			
			</strong>
			</div></td>
			<td>&nbsp;</td>
		  </tr>
		  <tr>
		  	<td align="right" height="25" valign="bottom">Mobile number</td>
			<td colspan="4" valign="bottom">
			<div style="border-bottom:solid 1px #000000;">
			<strong><%=WI.getStrValue((String)vRetResult.elementAt(7))%></strong>
			</div></td>
			<td>&nbsp;</td>
		  </tr>
		  <tr>
		  		<td colspan="8" height="25">&nbsp;</td>
		  </tr>
		  <tr>
			<td align="right" height="25" valign="bottom">Mother's name</td>		
			<td width="18%" valign="bottom">
			<div style="border-bottom:solid 1px #000000;">
			<strong><%=WI.getStrValue((String)vRetResult.elementAt(11))%></strong>
			</div></td> 
			<td width="9%" align="right" valign="bottom">Occupation</td> 
			<td width="13%" valign="bottom">
			<div style="border-bottom:solid 1px #000000;">
			<strong><%=WI.getStrValue((String)vRetResult.elementAt(12))%></strong>
			</div></td>
			<td width="11%" align="right" valign="bottom">Contact info</td>
			<td colspan="2" valign="bottom">
			<div style="border-bottom:solid 1px #000000;">
			<strong><%=WI.getStrValue((String)vRetResult.elementAt(13))%></strong>
			</div></td>
			<td width="5%">&nbsp;</td>
		  </tr>
		  <tr>
			<td align="right" height="25" valign="bottom">Father's name</td>
			<td valign="bottom">
			<div style="border-bottom:solid 1px #000000;">
			<strong><%=WI.getStrValue((String)vRetResult.elementAt(8))%></strong>
			</div></td>
			<td align="right" valign="bottom">Occupation</td>
			<td valign="bottom">
			<div style="border-bottom:solid 1px #000000;">
			<strong><%=WI.getStrValue((String)vRetResult.elementAt(9))%></strong>
			</div></td>
			<td align="right" valign="bottom">Contact info</td>
			<td colspan="2" valign="bottom">
			<div style="border-bottom:solid 1px #000000;">
			<strong><%=WI.getStrValue((String) vRetResult.elementAt(10))%></strong>
			</div></td>
			<td>&nbsp;</td>
		  </tr>
		  <tr>
			<td align="right" height="25" valign="bottom">Spouse's name</td>
			<td valign="bottom">
			<div style="border-bottom:solid 1px #000000;">&nbsp;
			<%=WI.getStrValue((String)vRetResult.elementAt(14))%>
			</div></td>
			<td align="right" valign="bottom">Occupation</td>
			<td valign="bottom">
			<div style="border-bottom:solid 1px #000000;">&nbsp;
			<%//=WI.getStrValue(,"&nbsp;")%>
			</div></td>
			<td valign="bottom" align="right">Contact info</td>
			<td valign="bottom" colspan="2">
			<div style="border-bottom: solid 1px #000000;">&nbsp;
			<%//=WI.getStrValue(,"&nbsp;")%>
			</div></td>
			<td>&nbsp;</td>
		  </tr>
		  <tr>
		  	<td align="right" height="25" valign="bottom">Seafer's Book #</td>
			<td colspan="3" valign="bottom">
			<% strTemp = WI.fillTextValue("field_1");
			   if(vEditInfo !=null && vEditInfo.size()>0)
			   		strTemp = (String)vEditInfo.elementAt(2);
			%>
			<input type="text" name="field_1" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" />
			</td>
			<td colspan="4">&nbsp;</td>
		  </tr>
		  <tr>
		  	<td align="right" height="25" valign="bottom">Sponsoring Company</td>
			<td colspan="3" valign="bottom">
			<% strTemp = WI.fillTextValue("field_2");
			   if(vEditInfo !=null && vEditInfo.size()>0)
			  	   strTemp = (String)vEditInfo.elementAt(3);
			%>
			<input type="text" name="field_2" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
			</td>
			<td colspan="4">&nbsp;</td>
		  </tr>
		  <tr>
		  	<td align="right" height="25" valign="bottom">Address</td>
			<td colspan="3" valign="bottom">
			<%strTemp = WI.fillTextValue("field_3");	
			  if(vEditInfo !=null && vEditInfo.size()>0)
			     strTemp = (String)vEditInfo.elementAt(4);
			%>
			<input type="text" name="field_3" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
			</td>
			<td colspan="4">&nbsp;</td>
		  </tr>
		  <tr>
		  	<td align="right" height="25" valign="bottom">Cadet Agreement</td>
			<td>&nbsp;</td>
			<td align="right" valign="bottom">Embarkation</td>
			<td valign="bottom">
			<%strTemp = WI.fillTextValue("field_4");
			  if(vEditInfo !=null  && vEditInfo.size()>0)
			     strTemp = (String) vEditInfo.elementAt(5);
			
			%>
			<input type="text" name="field_4" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
			</td>
			<td valign="bottom" align="right">Disembarkation</td>
			<td valign="bottom" colspan="2">
			<% strTemp = WI.fillTextValue("field_5");
			   if(vEditInfo!=null && vEditInfo.size()>0)
			   		strTemp = (String) vEditInfo.elementAt(6);
			
			%>
			<input type="text" name="field_5" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
			</td>
		  </tr>
		  <tr>
		  	 <td valign="bottom" align="right" height="25">Change of Sponsoring Company (If applicable)</td>
			 <td colspan="7">&nbsp;</td>		  
		  </tr>
		  <tr>
		  	 <td valign="bottom" align="right" height="25">Address</td>
			 <td valign="bottom" colspan="3">
			 <%	strTemp = WI.fillTextValue("field_6");
				if(vEditInfo !=null && vEditInfo.size()>0)
					strTemp = (String) vEditInfo.elementAt(7);
			 %>
			 <input type="text" name="field_6" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			 onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
			 </td>
			 <td colspan="4">&nbsp;</td>
		  </tr>
		  <tr>
		  	 <td valign="bottom" align="right" height="25">Cadet Agreement</td>
			 <td>&nbsp;</td>
			 <td valign="bottom" align="right">Embarkation</td>
			 <td valign="bottom">
			 <%	strTemp = WI.fillTextValue("field_7");
				if(vEditInfo !=null && vEditInfo.size()>0)
					strTemp = (String) vEditInfo.elementAt(8);				
			 %>
			 <input type="text" name="field_7" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			 onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
			 </td>
			 <td valign="bottom" align="right">Disembarkation</td>
			 <td valign="bottom" colspan="2"> 
			 <%strTemp= WI.fillTextValue("field_8");
			   if(vEditInfo!=null && vEditInfo.size()>0)
			   		strTemp  = (String) vEditInfo.elementAt(9);			 
			 %>
			 <input type="text" name="field_8" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			 onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
			 </td>
		  </tr>
		  <tr>
		      <td class="8" height="25">&nbsp;</td>
		  </tr>
		  <tr>
	          <td height="25" valign="bottom">SCHOOL INFORMATION</td>
		      <td colspan="7">&nbsp;</td>
		  </tr>	
		  <tr>
		  	  <td align="right" height="25" valign="bottom">Academic Awards</td>
			  <td colspan="3" valign="bottom">
			  <%strTemp= WI.fillTextValue("field_9");
			    if(vEditInfo !=null && vEditInfo.size()>0)
					strTemp=(String) vEditInfo.elementAt(10);
			  
			  %>
			  <input type="text" name="field_9" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
			  </td>
			  <td colspan="4">&nbsp;</td>
		  </tr>	  
		  <tr>
		  	  <td align="right" valign="bottom" height="25">Awards</td>
			  <td colspan="3" valign="bottom">
			  <%strTemp = WI.fillTextValue("field_10");
			    if(vEditInfo!=null && vEditInfo.size()>0)
					strTemp = (String) vEditInfo.elementAt(11);
			  %>
			  <input type="text" name="field_10" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"/>
			  </td>
			  <td colspan="4">&nbsp;</td>
		  </tr>
		  <tr>
		     <td align="right" height="25" valign="bottom">LGU Sponsor</td>
			 <td colspan="3" valign="bottom">
			 <%strTemp = WI.fillTextValue("field_11");
			   if(vEditInfo !=null && vEditInfo.size()>0)
			   	  strTemp= (String) vEditInfo.elementAt(12);			 
			 %>
			 <input type="text" name="field_11" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			 onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
			 </td>
			 <td colspan="4">&nbsp;</td>
		  </tr>
		  <tr>
		  	  <td colspan="8" height="30">&nbsp;</td>
		  </tr>
       </table>
	   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	      <tr>
		  	<td height="25"><strong>FOR  SHIPBOARD TRAINING OFFICE USE</strong></td>
		  </tr>
		  <tr>
		  	<td height="25"><strong>BASIC TRAINING AS REQUIRED OF THE STCW CODE</strong></td>
		  </tr>
		  <tr>
		  	<td height="25"><strong><font size="1">As part of your pre-sea training you should have completed Basic Training or instructions as listed. Enter deatils of this training or instruction below.</font></strong></td>
		  </tr>
	   </table>
	   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	   		<tr>
				<td height="25" width="27%" class="thinborder">&nbsp;</td>
				<td width="24%" class="thinborder" align="center">Date</td>
				<td width="26%" class="thinborder" align="center">Location</td>
				<td width="23%" class="thinborder" align="center">Document #(if any)</td>
			</tr>
			<tr>
				<td height="25" class="thinborder">Personal Survival Techniques </td>
				<td class="thinborder">
				<% if(vEditInfo !=null && vEditInfo.size()>0)
				   		strTemp= (String)vEditInfo.elementAt(13);
				   else	
					    strTemp = WI.fillTextValue("field_12_date");
				   if(WI.getStrValue(strTemp).length()==0)
				   		strTemp = WI.getTodaysDate(1);
				%>
				<input name="field_12_date" type="text" size="12" maxlength="12" readonly="yes" 
				value="<%=WI.getStrValue(strTemp)%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.field_12_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
				</td>
				<td class="thinborder">
				<%strTemp = WI.fillTextValue("field_13");
				  if(vEditInfo !=null && vEditInfo.size()>0)
				  	 strTemp = (String) vEditInfo.elementAt(14);
				%>
				<input type="text" name="field_13" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				</td>
				<td class="thinborder">
				<%strTemp = WI.fillTextValue("field_14");
				  if(vEditInfo!=null && vEditInfo.size()>0)
				  	 strTemp = (String) vEditInfo.elementAt(15);
				%>
				<input type="text" name="field_14" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
			</tr>
			<tr>
				<td height="25" class="thinborder">Fire Prevention & Fire Fighting</td>
				<td class="thinborder">
				<%if(vEditInfo!=null && vEditInfo.size()>0)
				  	strTemp= (String)vEditInfo.elementAt(16);	
				  else
				  	strTemp = WI.fillTextValue("field_15_date");
				  if(WI.getStrValue(strTemp).length()==0)
				  	  strTemp = WI.getTodaysDate(1);
				%>
				<input name="field_15_date" type="text" size="12" maxlength="12" readonly="yes" 
				value="<%=WI.getStrValue(strTemp)%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.field_15_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
				</td>
				<td class="thinborder">
				<% strTemp = WI.fillTextValue("field_16");
				   if(vEditInfo!=null && vEditInfo.size()>0)
				      strTemp= (String)vEditInfo.elementAt(17);
				%>
				<input type="text" name="field_16" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				</td>
				<td class="thinborder">
				<% strTemp = WI.fillTextValue("field_17");
				   if(vEditInfo !=null && vEditInfo.size()>0)
				   		strTemp = (String) vEditInfo.elementAt(18);
				%>
				<input type="text" name="field_17" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				</td>
			</tr>
			<tr>
				<td height="25" class="thinborder">Elementary First Aid</td>
				<td class="thinborder">
				<% if(vEditInfo!=null && vEditInfo.size()>0)
				   		strTemp = (String) vEditInfo.elementAt(19);
				   else
					    strTemp = WI.fillTextValue("field_18_date");
				   if(WI.getStrValue(strTemp).length()==0)
				   		strTemp= WI.getTodaysDate(1);					
				%>
				<input name="field_18_date" type="text" size="12" maxlength="12" readonly="yes" 
				value="<%=WI.getStrValue(strTemp)%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.field_18_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
				</td>
				<td class="thinborder">
				<% strTemp =WI.fillTextValue("field_19");
				   if(vEditInfo !=null && vEditInfo.size()>0)
				   		strTemp = (String)vEditInfo.elementAt(20);
				%>
				<input type="text" name="field_19" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				</td>
				<td class="thinborder">
				<% strTemp = WI.fillTextValue("field_20");
				   if(vEditInfo !=null && vEditInfo.size()>0)
				     strTemp = (String) vEditInfo.elementAt(21);				
				%>
				<input type="text" name="field_20" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				</td>
			</tr>
			<tr>
				<td height="25" class="thinborder">Personal Safety and Social Responsibilities</td>
				<td class="thinborder">
				<% if(vEditInfo !=null && vEditInfo.size()>0)
				      strTemp = (String) vEditInfo.elementAt(22);
				   else
				      strTemp= WI.fillTextValue("field_21_date");
				   if(WI.getStrValue(strTemp).length()==0)
				   		strTemp =WI.getTodaysDate(1);
				%>
				<input name="field_21_date" type="text" size="12" maxlength="12" readonly="yes" 
				value="<%=WI.getStrValue(strTemp)%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.field_21_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
				<td class="thinborder">
				<% strTemp= WI.fillTextValue("field_22");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(23);
				%>
				<input type="text" name="field_22" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<td class="thinborder">
				<% strTemp = WI.fillTextValue("field_23");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(24);
				%>
				<input type="text" name="field_23" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			</tr>
			<tr>
				<td height="25" class="thinborder">Others</td>
				<td class="thinborder">
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(25);
				   else
					  strTemp= WI.fillTextValue("field_24_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp =WI.getTodaysDate(1);
				%>
				<input name="field_24_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.field_24_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
				</td>
				<td class="thinborder">
				<% strTemp = WI.fillTextValue("field_25");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(26);
				%>
				<input type="text" name="field_25" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				</td>
				<td class="thinborder">
				<% strTemp = WI.fillTextValue("field_26");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(27);
				%>
				<input type="text" name="field_26" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				</td>
			</tr>
	   </table>
	   <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	       <tr>
		   		<td height="25"><strong>Record of Other Training</strong></td>
		   </tr>
	   </table>
	   <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	       <tr>
		   		<td width="27%" height="25" class="thinborder">&nbsp;</td>
				<td width="24%" align="center" class="thinborder">Date</td>
				<td width="26%" align="center" class="thinborder">Location</td>
				<td width="23%" align="center" class="thinborder">Document #(if any)</td>
		   </tr>
		   <tr>
		   		<td class="thinborder" height="25">Proficiency in Survival Craft & Rescue Boats</td>
				<td class="thinborder">
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(28);
				   else
					  strTemp= WI.fillTextValue("field_27_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp =WI.getTodaysDate(1);
				%>
				<input name="field_27_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.field_27_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
				</td>
				<td class="thinborder">
				<% strTemp = WI.fillTextValue("field_28");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(29);
				%>
				<input type="text" name="field_28" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				</td>
				<td class="thinborder">
				<% strTemp = WI.fillTextValue("field_29");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(30);
				%>
				<input type="text" name="field_29" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				</td>
		   </tr>
		   <tr>
		   		<td class="thinborder" height="25">Proficiency in Fast Rescue Boats</td>
				<td class="thinborder">
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(31);
				   else
					  strTemp= WI.fillTextValue("field_30_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp =WI.getTodaysDate(1);
				%>
				<input name="field_30_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.field_30_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	            <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
				</td>
				<td class="thinborder">
				<% strTemp = WI.fillTextValue("field_31");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(32);
				%>
				<input type="text" name="field_31" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				</td>
				<td class="thinborder">
				<% strTemp = WI.fillTextValue("field_32");
				 if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(33);
				%>
				<input type="text" name="field_32" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				</td>
		   </tr>
		   <tr>
		   	    <td class="thinborder" height="25">Others</td>
				<td class="thinborder">
				<% if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(34);
				   else
					    strTemp= WI.fillTextValue("field_33_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp =WI.getTodaysDate(1);
				%>
				<input name="field_33_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_33_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
				</td>
				<td class="thinborder">
				<% strTemp = WI.fillTextValue("field_34");
				  if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(35);
				%>
				<input type="text" name="field_34" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				</td>
				<td class="thinborder">
				<% strTemp = WI.fillTextValue("field_35");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(36);
				%>
				<input type="text" name="field_35" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				</td>
		   </tr>		   
	   </table>
	   <table width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#FFFFFF">
	   		<tr>
				<td height="25"><strong>FOR ALUMNI/SNPL USE</strong></td>
			</tr>
			<tr>
				<td height="25"><strong>SHIPBOARD SERVICE RECORD</strong></td>
			</tr>
	   </table>
	   <table width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#FFFFFF" class="thinborder">
	        <tr>
				<td width="17%" height="25" rowspan="2" align="center" class="thinborder"><strong>Principal</strong></td>
				<td width="11%" rowspan="2" align="center" class="thinborder"><strong>Type of vessel</strong></td>
				<td width="9%" rowspan="2" align="center" class="thinborder"><strong>Position</strong></td>
				<td width="7%" rowspan="2" align="center" class="thinborder"><strong>Allotment</strong></td>
				<td width="6%" rowspan="2" align="center" class="thinborder"><strong>SNPL</strong></td>
				<td class="thinborder" align="center" colspan="2"><strong>Dates</strong></td>
				<td width="10%" rowspan="2" align="center" class="thinborder"><strong>Last Contact</strong></td>
				<td width="6%" rowspan="2" align="center" class="thinborder"><strong>Status</strong></td>
				<td class="thinborder" align="center" colspan="2"><strong>Seagoing service</strong></td>
			</tr>
			<tr>
				<td width="9%" height="25" align="center" class="thinborder"><strong>Embarkation</strong></td>
				<td width="11%" align="center" class="thinborder"><strong>Disembarkation</strong></td>
				<td width="8%" align="center" class="thinborder"><strong>Months</strong></td>
				<td width="6%" align="center" class="thinborder"><strong>Days</strong></td>
			</tr>
			<tr>
			    <% strTemp = WI.fillTextValue("field_36");
			       if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(37);
				%>
				<td height="25" class="thinborder">1. 
				<input type="text" name="field_36" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp =WI.fillTextValue("filed_37");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(38);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_37" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_38");
				  if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(39);
				%>
				<td class="thinborder">
				<input type="text" name="field_38" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_39");
				  if(vEditInfo !=null && vEditInfo.size()>0)
					   strTemp = (String) vEditInfo.elementAt(40);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_39" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp =WI.fillTextValue("field_40");
				 if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(41);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_40" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(42);
				   else
					  strTemp= WI.fillTextValue("field_41_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp =WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">
				<input name="field_41_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_41_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(43);
				   else
					  strTemp= WI.fillTextValue("field_42_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp =WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">
				<input name="field_42_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_42_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </td>
				<% strTemp = WI.fillTextValue("field_43");
				  if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(44);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_43" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_44");
				 if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(45);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_44" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp =WI.fillTextValue("field_45");
				 if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(46);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_45" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_46");
				 if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(47);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_46" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
			</tr>
			<tr>
				<% strTemp = WI.fillTextValue("field_47");
				 if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(48);
				%>
				<td height="25" class="thinborder">2. 
				<input type="text" name="field_47" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_48");
				 if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(49);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_48" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_49");
				 if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(50);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_49" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_50");
				 if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(51);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_50" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_51");
				  if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(52);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_51" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(53);
				   else
					  strTemp= WI.fillTextValue("field_52_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp =WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">
				<input name="field_52_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_52_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(54);
				   else
					  strTemp= WI.fillTextValue("field_53_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp =WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">
				<input name="field_53_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_53_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
				<% strTemp = WI.fillTextValue("field_54");
				 if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(55);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_54" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_55");
				  if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(56);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_55" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_56");
				 if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(57);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_56" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_57");
				 if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(58);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_57" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				
			</tr>
			<tr>
				<% strTemp = WI.fillTextValue("field_58");
				 if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(59);
				%>
				<td height="25" class="thinborder">3. 
				<input type="text" name="field_58" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_59");
				 if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(60);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_59" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_60");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(61);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_60" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_61");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(62);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_61" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_62");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(63);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_62" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(64);
				   else
					  strTemp= WI.fillTextValue("field_63_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp =WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">
				<input name="field_63_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_63_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(65);
				   else
					  strTemp= WI.fillTextValue("field_64_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp =WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">
				<input name="field_64_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_64_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </td>
				<% strTemp = WI.fillTextValue("field_65");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(66);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_65" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_66");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(67);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_66" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_67");
				 if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(68);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_67" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_68");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(69);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_68" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
			</tr>
			<tr>
				<% strTemp = WI.fillTextValue("field_69");
				  if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(70);
				%>
				<td height="25" class="thinborder">4. 
				<input type="text" name="field_69" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_70");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(71);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_70" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_71");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(72);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_71" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_72");
					if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(73);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_72" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_73");
					if(vEditInfo !=null && vEditInfo.size()>0)
							strTemp = (String) vEditInfo.elementAt(74);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_73" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(75);
				   else
				   	  strTemp = WI.fillTextValue("field_74_date");
				   if(WI.getStrValue(strTemp).length()==0)
				   		strTemp= WI.getTodaysDate(1);				
				%>
				<td height="25" class="thinborder">
				<input name="field_74_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_74_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
				<% 
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(76);
				   else
				      strTemp = WI.fillTextValue("field_75_date");
				   if(WI.getStrValue(strTemp).length()==0)
				      strTemp = WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">
				<input name="field_75_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_75_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
				<% strTemp = WI.fillTextValue("field_76");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(77);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_76" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_77");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(78);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_77" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_78");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(79);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_78" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_79");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(80);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_79" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
			</tr>
			<tr>
			    <% strTemp = WI.fillTextValue("field_80");
			       if(vEditInfo !=null && vEditInfo.size()>0)
			    	  strTemp = (String) vEditInfo.elementAt(81);
				%>
				<td height="25" class="thinborder">5. 
				<input type="text" name="field_80" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_81");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(82);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_81" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_82");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(83);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_82" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_83");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(84);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_83" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_84");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(85);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_84" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(86);
				   else
						strTemp = WI.fillTextValue("field_85_date");
				   if(WI.getStrValue(strTemp).length()==0)
				       strTemp = WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">
				<input name="field_85_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_85_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </td>
				<%  if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(87);
					else
						strTemp = WI.fillTextValue("field_86_date");
					if(WI.getStrValue(strTemp).length()==0)
						strTemp = WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">
				<input name="field_86_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_86_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
				<% strTemp = WI.fillTextValue("field_87");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(88);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_87" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<%  strTemp = WI.fillTextValue("field_88");
					if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(89);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_88" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<%   strTemp = WI.fillTextValue("field_89");
					 if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(90);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_89" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_90");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(91);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_90" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
			</tr>
			<tr>
			 	<%  strTemp = WI.fillTextValue("field_91");
					if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(92);
				%>
				<td height="25" class="thinborder">6. 
				<input type="text" name="field_91" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			    <%  strTemp = WI.fillTextValue("field_92");
			    	if(vEditInfo !=null && vEditInfo.size()>0)
			    		strTemp = (String) vEditInfo.elementAt(93);
				%>
			    <td height="25" class="thinborder">
				<input type="text" name="field_92" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_93");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(94);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_93" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_94");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 	strTemp = (String) vEditInfo.elementAt(95);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_94" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_95");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(96);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_95" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<%   if(vEditInfo !=null && vEditInfo.size()>0)
					   strTemp = (String) vEditInfo.elementAt(97);
					 else
					   strTemp = WI.fillTextValue("field_96_date");
					 if(WI.getStrValue(strTemp).length()==0)
					    strTemp= WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">
				<input name="field_96_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_96_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(98);
				   else
				   	  strTemp = WI.fillTextValue("field_97_date");
				   if(WI.getStrValue(strTemp).length()==0)
				   		strTemp = WI.getTodaysDate(1);				
				%>
				<td height="25" class="thinborder">
				<input name="field_97_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_97_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </td>
				<% strTemp = WI.fillTextValue("field_98");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(99);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_98" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_99");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(100);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_99" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_100");
				   if(vEditInfo !=null && vEditInfo.size()>0)
				      strTemp = (String) vEditInfo.elementAt(101);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_100" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_101");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(102);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_101" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
			</tr>
			<tr>
				<% strTemp = WI.fillTextValue("field_102");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					strTemp = (String) vEditInfo.elementAt(103);
				%>
				<td height="25" class="thinborder">7. 
				<input type="text" name="field_102" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_103");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					   strTemp = (String) vEditInfo.elementAt(104);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_103" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_104");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(105);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_104" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_105");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(106);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_105" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_106");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(107);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_106" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(108);
				   else
				     strTemp = WI.fillTextValue("field_107_date");
				   if(WI.getStrValue(strTemp).length()==0)
				      strTemp = WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">
				<input name="field_107_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_107_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(109);
				   else
				   	   strTemp = WI.fillTextValue("field_108_date");
				   if(WI.getStrValue(strTemp).length()==0)
						strTemp = WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">
				<input name="field_108_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_108_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
				<% strTemp = WI.fillTextValue("field_109");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(110);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_109" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_110");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(111);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_110" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_111");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(112);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_111" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_112");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					   strTemp = (String) vEditInfo.elementAt(113);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_112" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
			</tr>
			<tr>
				<% strTemp = WI.fillTextValue("field_113");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(114);
				%>
				<td height="25" class="thinborder">8.
				<input type="text" name="field_113" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_114");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(115);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_114" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_115");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(116);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_115" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_116");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(117);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_116" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_117");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(118);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_117" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(119);
				   else
				       strTemp = WI.fillTextValue("field_118_date");
				   if(WI.getStrValue(strTemp).length()==0)
				   		strTemp =WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">
				<input name="field_118_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_118_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(120);
				   else
				     strTemp = WI.fillTextValue("field_119_date");
				   if(WI.getStrValue(strTemp).length()==0)
				   		strTemp = WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">
				<input name="field_119_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_119_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
				<% strTemp = WI.fillTextValue("field_120");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					strTemp = (String) vEditInfo.elementAt(121);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_120" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_121");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(122);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_121" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_122");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(123);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_122" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_123");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(124);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_123" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
			</tr>
			<tr>
				<% strTemp = WI.fillTextValue("field_124");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(125);
				%>
				<td height="25" class="thinborder">9. 
				<input type="text" name="field_124" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_125");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(126);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_125" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_126");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(127);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_126" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_127");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					strTemp = (String) vEditInfo.elementAt(128);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_127" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_128");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					   strTemp = (String) vEditInfo.elementAt(129);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_128" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(130);
				   else
				      strTemp = WI.fillTextValue("field_129_date");
					if(WI.getStrValue(strTemp).length()==0)
					   strTemp = WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">
				<input name="field_129_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_129_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(131);
				   else
				      strTemp =  WI.fillTextValue("field_130_date");
				   if(WI.getStrValue(strTemp).length()==0)
				   		strTemp = WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">
				<input name="field_130_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_130_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </td>
				<% strTemp = WI.fillTextValue("field_131");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(132);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_131" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_132");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(133);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_132" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_133");
				   if(vEditInfo !=null && vEditInfo.size()>0)
				    	strTemp = (String) vEditInfo.elementAt(134);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_133" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_134");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(135);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_134" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			</tr>
			<tr>
				<% strTemp = WI.fillTextValue("field_135");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					   strTemp = (String) vEditInfo.elementAt(136);
				%>
				<td height="25" class="thinborder">10. 
				<input type="text" name="field_135" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_136");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(137);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_136" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_137");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					strTemp = (String) vEditInfo.elementAt(138);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_137" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_138");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(139);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_138" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_139");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(140);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_139" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(141);
				   else
				      strTemp = WI.fillTextValue("field_140_date");
				   if(WI.getStrValue(strTemp).length()==0)
				      strTemp = WI.getTodaysDate();
				%>
				<td height="25" class="thinborder">
				<input name="field_140_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_140_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
				<%  if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(142);
				    else
					   strTemp = WI.fillTextValue("field_141_date");
					if(WI.getStrValue(strTemp).length()==0)
					   strTemp = WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">
				<input name="field_141_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_141_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </td>
				<% strTemp = WI.fillTextValue("field_142");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(143);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_142" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_143");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(144);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_143" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_144");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(145);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_144" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_145");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					strTemp = (String) vEditInfo.elementAt(146);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_145" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
			</tr>
			<tr>     
				<td height="25" class="thinborder">Total Service</td>
				<% strTemp = WI.fillTextValue("field_146");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(147);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_146" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_147");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(148);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_147" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_148");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					 strTemp = (String) vEditInfo.elementAt(149);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_148" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_149");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(150);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_149" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(151);
				   else
				      strTemp = WI.fillTextValue("field_150_date");
				   if(WI.getStrValue(strTemp).length()==0)
					   strTemp = WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">				
				<input name="field_150_date" type="text" size="12" maxlength="12" readonly="yes" 
				value="<%=WI.getStrValue(strTemp)%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_150_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(152);
				   else
				        strTemp = WI.fillTextValue("field_151_date");
				   if(WI.getStrValue(strTemp).length()==0)
				      strTemp = WI.getTodaysDate(1);
				%>
				<td height="25" class="thinborder">				
				<input name="field_151_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_151_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
				</td>
				<% strTemp = WI.fillTextValue("field_152");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(153);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_152" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
 				</td>
				<% strTemp = WI.fillTextValue("field_153");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(154);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_153" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_154");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(155);
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_154" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
				<% strTemp = WI.fillTextValue("field_155");
				   if(vEditInfo !=null && vEditInfo.size()>0)
				      strTemp = (String) vEditInfo.elementAt(156);  
				%>
				<td height="25" class="thinborder">
				<input type="text" name="field_155" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
			</tr>
	   </table>
	   <table width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#FFFFFF">
	   		<tr>
				<td height="25"><strong>LEGAL MATTERS</strong></td>
			</tr>
	   </table>
	   <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
	    	<tr>
				<td height="25" class="thinborder">&nbsp;</td>
				<td class="thinborder" align="center"><strong>Reciever</strong></td>
				<td class="thinborder" align="center"><strong>Address</strong></td>
				<td class="thinborder" align="center"><strong>Date</strong></td>
			</tr>
			<tr>
				<td height="25" class="thinborder" align="center">Notice Letter</td>
				<% strTemp = WI.fillTextValue("field_156");
				   if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(157);
				%>
				<td class="thinborder">
				<input type="text" name="field_156" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_157");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(158);
				%>
				<td class="thinborder">
				<input type="text" name="field_157" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
					  strTemp = (String) vEditInfo.elementAt(159);
				   else 
				       strTemp = WI.fillTextValue("field_158_date");
				   if(WI.getStrValue(strTemp).length()==0)
				      strTemp = WI.getTodaysDate(1);				   
				%>
				<td class="thinborder">
				<input name="field_158_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.field_158_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
				</td>
			</tr>
			<tr>
				<td height="25" class="thinborder" align="center">1st Demand Letter</td>
				<% strTemp = WI.fillTextValue("field_159");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(160);
				%>
				<td class="thinborder">
				<input type="text" name="field_159" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_160");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(161);
				%>
				<td class="thinborder">
				<input type="text" name="field_160" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
				      strTemp = (String) vEditInfo.elementAt(162); 
				   else
				      strTemp = WI.fillTextValue("field_161_date");
				   if(WI.getStrValue(strTemp).length()==0)
				      strTemp = WI.getTodaysDate(1);
				%>
				<td class="thinborder">
				<input name="field_161_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.field_161_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
				</td>
			</tr>
			<tr>
				<td height="25" class="thinborder" align="center">Final Demand Letter</td>
				<% strTemp = WI.fillTextValue("field_162");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(163);
				%>
				<td class="thinborder">
				<input type="text" name="field_162" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_163");
				   if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(164);
				%>
				<td class="thinborder">
				<input type="text" name="field_163" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(165);
				   else
					     strTemp = WI.fillTextValue("field_164_date");
				   if(WI.getStrValue(strTemp).length()==0)
				      strTemp =WI.getTodaysDate(1);
				%>
				<td class="thinborder">
				<input name="field_164_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.field_164_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
			</tr>
			<tr>
				<td height="25" class="thinborder" align="center">Court Filling</td>
				<% strTemp = WI.fillTextValue("field_165");
				 if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(166);
				%>
				<td class="thinborder">
				<input type="text" name="field_165" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<% strTemp = WI.fillTextValue("field_166");
				 if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(167);
				%>
				<td class="thinborder">
				<input type="text" name="field_166" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				<%
				  if(vEditInfo !=null && vEditInfo.size()>0)
						strTemp = (String) vEditInfo.elementAt(168);
				  else 
				        strTemp = WI.fillTextValue("field_167");
			      if(WI.getStrValue(strTemp).length()==0)
				     strTemp = WI.getTodaysDate(1); 
				%>
				<td class="thinborder">
				<input name="field_167_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.field_167_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
			</tr>
	   </table>
	   <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
	   		<tr>
				<td height="25">Note</td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td height="25">Embarkation & Disembarkation(12 months)</td>
				<td>notify after 12 months</td>
			</tr>
			<tr>
				<td height="25">E1/E2</td>
				<td>notify after 10 months</td>
			</tr>
	   </table>
	   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	   	<tr>
	   		<Td colspan="3">&nbsp;</Td>
	   	</tr>
	   	<tr>
	   		<td height="25" colspan="5"><div align="center">
	   			  <%if(iAccessLevel > 1){
	   					    if(strPrepareToEdit.equals("1")){%>
	   							<a href="javascript:EditRecord('<%=WI.fillTextValue("info_index")%>');">
	   							<img src="../../../images/edit.gif" border="0"></a>
	   						    <font size="1">click to edit entries</font>
	   				      <%}else{%>
	   						    <a href="javascript:UpdateRecord();"><img src="../../../images/save.gif" border="0"></a>
	   							<font size="1">click to save entries</font>
	   				      <%}
	   				}else{%>
	   					    <font size="1">Not authorized to change information</font>
	   			  <%}%>
	   				    <a href="javascript:ReloadPage();"><img src="../../../images/cancel.gif" border="0"></a>
	   					<font size="1">click to cancel/erase entries</font></font></div></td>
	   	</tr>
</table>
<%}//end of vRetResult[0] !=null && vRetResult[0].size()>0%>
<%if(vRecords != null && vRecords.size() > 0){%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td>&nbsp;</td></tr>
</table>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr> 
		 <td height="20" colspan="6" bgcolor="#B9B292" class="thinborder" align="center">
		 <strong>::: LIST OF STUDENT RECORDS :::</strong></td>
	</tr>
	<tr>
		<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>				
		<td width="15%" align="center" class="thinborder"><strong>Recorded Date</strong></td>
		<td width="15%" align="center" class="thinborder"><strong>Updated Date</strong></td>
		<td width="25%" align="center" class="thinborder"><strong>Updated By</strong></td>
		<td width="20%" align="center" class="thinborder"><strong>Options</strong></td>
	</tr>
<%	int iCount = 1;
	for(int i = 0; i < vRecords.size(); i+=4){%>
	<tr>
		<td height="25" align="center" class="thinborder"><%=iCount++%></td>			    
		<td class="thinborder"><%=WI.getStrValue((String)vRecords.elementAt(i+1),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRecords.elementAt(i+2),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRecords.elementAt(i+3),"&nbsp;")%></td>
		<td align="center" class="thinborder">
		<%if(iAccessLevel > 1){%>
				<a href="javascript:PrepareToEdit('<%=(String)vRecords.elementAt(i)%>');">
				<img src="../../../images/edit.gif" border="0"></a>
			<%if(iAccessLevel == 2){%>
				&nbsp;
				<a href="javascript:DeleteRecord('<%=(String)vRecords.elementAt(i)%>')">
				<img src="../../../images/delete.gif" border="0"></a>
			<%}%>
			<a href="javascript:PrintPg('<%=(String)vRecords.elementAt(i)%>');">
			<img src="../../../images/print.gif" border="0"></a>
		<%}else{%>
			No edit/delete privilege.
		<%}%>
		</td>
	</tr>
<%}//end of vRecords loop%>
</table>
<%} // end of vRecords !=null && vRecords.size()>0%>
<table  width="100%" border="0" cellpadding="0" cellspacing="0" >
	<tr>
		<td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
	</tr>
	<tr>
		<td height="25" colspan="9" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
	</tr>
</table>      
       <input type="hidden" name="no_of_fields" value="167" > <!-- get the last number of fields; used in java -->
       <input type="hidden" name="print_page">
       <input type="hidden" name="reload_page">
       <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
       <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
       <input type="hidden" name="view_fields" value="<%=strViewFields%>">
       <input type="hidden" name="page_action">
       <input type="hidden" name="vDate" value="12,15,18,21,24,27,30,33,41,42,52,53,63,64,74,75,85,86,96,97,107,108,118,119,129,130,140,141,150,151,158,161,164,167">
     </form>
     </body>
     </html>
     <% dbOP.cleanUP(); %>
