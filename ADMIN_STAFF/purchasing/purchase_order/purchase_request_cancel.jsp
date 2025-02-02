<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function PageLoad(){
 	document.form_.req_no.focus();
}
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function DeleteClicked(strPO){
	var vProceed = confirm('Cancel '+strPO+' ?');
	if(vProceed){
		document.form_.deleteClicked.value = "1";
		document.form_.proceedClicked.value = "1";
		this.SubmitOnce('form_');
	}
}
function CancelClicked(){
	location = "./purchase_request_cancel.jsp";
}
function OpenSearchPO(){
	var pgLoc = "./purchase_request_view_search.jsp?opner_info=form_.req_no&status=1";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()">
<%@ page language="java" import="utility.*,purchasing.PO,purchasing.Requisition,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Purchasing-Purchase Order","purchase_request_cancel.jsp");
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
														"PURCHASING","PURCHASE ORDER",request.getRemoteAddr(),
														"purchase_request_cancel.jsp");
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
	
	Requisition REQ = new Requisition();
	PO PO = new PO();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vReqPO = null;
	boolean bolIsErr = false;
	boolean bolIsInPO = false;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String strReqIndex  = null;
	double dTotalAmount = 0d;
	

	if(WI.fillTextValue("proceedClicked").equals("1")){
		vReqInfo = PO.operateOnReqInfo(dbOP,request,3);
		if(vReqInfo == null){					
			strErrMsg = PO.getErrMsg();
		}else{			
		  strReqIndex = (String)vReqInfo.elementAt(1);
			if(WI.fillTextValue("deleteClicked").equals("1"))
			  vReqInfo = PO.operateOnReqInfoPO(dbOP,request,5,(String)vReqInfo.elementAt(0));
				if(vReqInfo == null)
				  strErrMsg = PO.getErrMsg();						
		}
		if(vReqInfo != null && vReqInfo.size() > 1){
			vReqPO = PO.operateOnPOInfo(dbOP,request,3,strReqIndex);
			if(vReqPO != null){
				bolIsInPO = true;					
				vReqItems = PO.operateOnPOItems(dbOP,request,4);
				if (vReqItems == null){				
					strErrMsg = PO.getErrMsg();									
					//vReqItems = REQ.operateOnReqItems(dbOP,request,4);
				}else{
					strErrMsg = PO.getErrMsg();
				}			
			}else{
				//vReqItems = REQ.operateOnReqItems(dbOP,request,4);				
				strErrMsg = PO.getErrMsg();					
			}
		}
	}
%>
<form name="form_" method="post" action="./purchase_request_cancel.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          PURCHASE </strong></font><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>ORDER</strong></font><font color="#FFFFFF"><strong> 
          - CANCEL PO PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="28%"> PO No. :</td>
      <td width="25%"> <%if(WI.fillTextValue("req_no").length() > 0){
	  		strTemp = WI.fillTextValue("req_no");
	  }else{
	  		strTemp = "";
      }%> <input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="44%"><a href="javascript:OpenSearchPO();"><img src="../../../images/search.gif" border="0"></a><font size="1">click to search po no.</font></td>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><a href="javascript:ProceedClicked();"> <img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td height="25">&nbsp;</td>
    </tr>
    <%if(vReqPO != null && vReqPO.size() > 2 && bolIsInPO){%>
    <tr> 
      <td height="25"> 
      <td>PO No. : <strong><%=(String)vReqPO.elementAt(1)%></strong></td>
      <td>PO Date : <strong><%=(String)vReqPO.elementAt(2)%></strong> </td>
      <td colspan="2">&nbsp;</td>	  
	</tr>    
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>
	<%}%>
  </table>
  <%if(vReqInfo != null && vReqInfo.size() > 3 && vReqPO != null && vReqPO.size() > 2 && bolIsInPO){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS FOR THIS PURCHASE ORDER</strong></div></td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="28%"><strong><%=(String)vReqInfo.elementAt(13)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"> <strong><%=(String)vReqInfo.elementAt(3)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(2))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vReqInfo.elementAt(6)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(11))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)%></strong></td>
    </tr>
	<%if(((String)vReqInfo.elementAt(4)).equals("0")){%> 
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=(String)vReqInfo.elementAt(10)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></strong></td>
    </tr>
	<%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)+"/"+WI.getStrValue((String)vReqInfo.elementAt(10),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(7),"&nbsp;")%></strong></td>
    </tr>
	<%}%>	
  </table>
    <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <%if(vReqItems != null && vReqItems.size() > 3){%>  
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="100%" height="25" bgcolor="#B9B292" colspan="8" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF PO ITEMS</strong></font></div></td>
    </tr>
    <tr> 
      <td width="8%" height="25" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="26%" class="thinborder"><div align="center"><strong>ITEM /PARTICULARS 
          / DESCRIPTION </strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>SUPPLIER 
          CODE </strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>BRAND</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
    </tr>
    <%for(int iLoop = 0;iLoop < vReqItems.size();iLoop+=12){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(iLoop+12)/12%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vReqItems.elementAt(iLoop+5)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+6)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+1)%> / <%=(String)vReqItems.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+3),"&nbsp;")%></div></td>
      <td class="thinborder"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+9),"&nbsp;")%></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+4),true),"&nbsp;")%></div></td>
      <% if(vReqItems.elementAt(iLoop+7) != null){
		  dTotalAmount += Double.parseDouble(ConversionTable.replaceString((String)vReqItems.elementAt(iLoop+7),",",""));	  }
	  %>
      <td class="thinborder"><div align="right"> 
          <%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
          &nbsp; 
          <%}else{%>
          <%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%> 
          <%}%>
        </div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="4" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=vReqItems.size()/12%></strong></div></td>
      <td height="25" colspan="3" class="thinborder"><div align="right"><strong>TOTAL 
          AMOUNT : </strong></font></div></td>
      <td height="25" class="thinborder"><div align="right"><strong><%=CommonUtil.formatFloat(dTotalAmount,true)%></strong></div></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="13%" height="20" class="thinborder"><strong>REMARKS:</strong></td>
	  <%
	  	strTemp = WI.fillTextValue("remarks");
	  %>
      <td width="87%" class="thinborder"><input name="remarks" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="44"></td>
    </tr>
  </table>  
  <%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"> <a href="javascript:DeleteClicked('<%=(String)vReqPO.elementAt(1)%>');"> 
          <img src="../../../images/delete.gif" border="0"> </a> <font size="1">click 
          to cancel this PO</font> <a href="javascript:CancelClicked();"> <img src="../../../images/cancel.gif" border="0"> 
          </a> <font size="1">click to cancel transaction</font> </div></td>
    </tr>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="is_supply" value="<%=WI.fillTextValue("is_supply")%>">
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="isForPO" value="1">
  <input type="hidden" name="deleteClicked" value="">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
